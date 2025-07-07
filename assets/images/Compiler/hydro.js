// ---------------- LEXICAL ANALYZER ---------------- //
const tokenSpec = [
  ['NUMBER', /^\d+(\.\d*)?/],
  ['ASSIGN', /^:=/],
  ['EQUALS', /^=/],
  ['COLON', /^:/],
  ['END', /^#/],
  ['KEYWORD', /^(check|otherwise|try else|cycle|keep going|until)\b/],
  ['COMPARE', /^(==|[<>]=?)/],
  ['ID', /^[A-Za-z_][A-Za-z0-9_]*/],
  ['OP', /^[+\-*/]/],
  ['LPAREN', /^\(/],
  ['RPAREN', /^\)/],
  ['STRING', /^"[^"]*"/],
  ['SINGLE_CHAR', /^'.'/],
  ['SINGLE_COMMENT', /^@.*?@/s],
  ['SKIP', /^[ \t\n\r]+/],
  ['MISMATCH', /^./]
];

function tokenize(code) {
  let index = 0;
  const tokens = [];
  const lines = code.split('\n');
  let line = 1, col = 1;

  while (index < code.length) {
    let foundMatch = false;

    for (const [type, regex] of tokenSpec) {
      const remaining = code.slice(index);
      const match = remaining.match(regex);
      if (match) {
        const value = match[0];
        if (type === 'SKIP') {
          const skipped = value.match(/\n/g);
          if (skipped) line += skipped.length;
          const lastLineBreak = value.lastIndexOf('\n');
          col = lastLineBreak !== -1 ? value.length - lastLineBreak : col + value.length;
        } else if (type !== 'MISMATCH') {
          tokens.push({ type, value, line, col });
        } else {
          tokens.push({ type: 'ERROR', value, line, col });
        }

        index += value.length;
        foundMatch = true;
        break;
      }
    }

    if (!foundMatch) {
      tokens.push({ type: 'ERROR', value: code[index], line, col });
      index++;
      col++;
    }
  }

  return tokens;
}

// ---------------- SYNTAX ANALYZER ---------------- //
class Parser {
  constructor(tokens) {
    this.tokens = tokens;
    this.current = 0;
    this.errors = [];
  }

  peek() {
    return this.tokens[this.current];
  }

  advance() {
    return this.tokens[this.current++];
  }

  match(...types) {
    const token = this.peek();
    if (token && types.includes(token.type)) {
      this.advance();
      return true;
    }
    return false;
  }

  expect(type, message) {
    const token = this.peek();
    if (!this.match(type)) {
      this.errors.push({
        message: message || `Expected ${type}, but found '${token?.value}'`,
        index: this.current,
        line: token?.line,
        col: token?.col
      });
    }
  }

  parse() {
    const ast = [];
    while (this.current < this.tokens.length) {
      const stmt = this.statement();
      if (stmt !== null) ast.push(stmt);
    }
    return ast;
  }

  statement() {
    const token = this.peek();
    if (!token) return null;

    // Skip empty statement: a lone '#'
    if (token.type === 'END') {
      this.advance(); // consume it
      return null;    // no AST node
    }

    if (token.type === 'KEYWORD') {
      if (token.value === 'check') {
        return this.declaration();
      } else if (['otherwise', 'try else', 'cycle', 'keep going', 'until'].includes(token.value)) {
        return this.control();
      }
    } else if (token.type === 'ID') {
      return this.assignment();
    } else {
      const expr = this.expression();
      this.expect('END', 'Expected # at the end of expression');
      return { type: 'ExprStatement', expression: expr };
    }
  }

  declaration() {
    this.advance(); // check (if ever used)
    const id = this.advance();
    this.expect('COLON');
    const type = this.advance();
    this.expect('END', 'Expected # after declaration');
    return { type: 'Declaration', id, valueType: type };
  }

  assignment() {
    const id = this.advance();
    this.expect('ASSIGN');
    const expr = this.expression();
    this.expect('END', 'Expected # after assignment');
    return { type: 'Assignment', id, expression: expr };
  }

  expression() {
    let left = this.term();
    
    // Handle comparison operators
    while (this.match('COMPARE')) {
      const operator = this.tokens[this.current - 1];
      const right = this.term();
      left = { type: 'BinaryExpr', left, operator, right };
    }
    
    // Handle arithmetic operators
    while (this.match('OP')) {
      const operator = this.tokens[this.current - 1];
      const right = this.term();
      left = { type: 'BinaryExpr', left, operator, right };
    }
    
    return left;
  }

  term() {
    const token = this.advance();
    if (['NUMBER', 'STRING', 'ID'].includes(token.type)) {
      return { type: 'Literal', value: token };
    } else if (token.type === 'LPAREN') {
      const expr = this.expression();
      this.expect('RPAREN');
      return expr;
    } else {
      this.errors.push({
        message: `Unexpected token '${token.value}'`,
        index: this.current,
        line: token.line,
        col: token.col
      });
      return { type: 'Error', token };
    }
  }

  control() {
    const keyword = this.advance(); // 'cycle', 'keep going', 'check', etc.

    this.expect('LPAREN', "Expected '(' after control keyword");
    const condition = this.expression();
    this.expect('RPAREN', "Expected ')' after control condition");
    this.expect('END', "Expected '#' after control statement");

    // Parse zero or more statements as the body until next END or EOF
    const bodyStatements = [];

    while (true) {
      const next = this.peek();
      if (!next || next.type === 'END') {
        if (next && next.type === 'END') this.advance(); // consume lone #
        break;
      }
      const stmt = this.statement();
      if (stmt) bodyStatements.push(stmt);
      else break;
    }

    return { type: 'Control', keyword, condition, body: bodyStatements };
  }
}

// ---------------- SEMANTIC ANALYZER ---------------- //
class SemanticAnalyzer {
  constructor(ast) {
    this.ast = ast;
    this.errors = [];
    this.globalScope = new Map();
    this.scopes = [this.globalScope];
  }

  currentScope() {
    return this.scopes[this.scopes.length - 1];
  }

  analyze() {
    for (const node of this.ast) {
      this.visit(node);
    }
  }

  visit(node) {
    if (!node) return;

    switch (node.type) {
      case 'Declaration':
        this.handleDeclaration(node);
        break;
      case 'Assignment':
        this.handleAssignment(node);
        break;
      case 'ExprStatement':
        this.checkExpression(node.expression);
        break;
      case 'Control':
        this.checkControl(node);
        break;
      default:
        this.error(`Unknown node type '${node.type}'`, node);
    }
  }

  handleDeclaration(node) {
    const name = node.id.value;
    const type = node.valueType.value;
    const scope = this.currentScope();
    if (scope.has(name)) {
      this.error(`Redeclaration of variable '${name}'`, node.id);
      return;
    }
    scope.set(name, { type, node });
  }

  handleAssignment(node) {
    const name = node.id.value;
    const sym = this.lookupSymbol(name);
    if (!sym) {
      this.error(`Undeclared variable '${name}' in assignment`, node.id);
      return;
    }
    const exprType = this.checkExpression(node.expression);
    if (!exprType) return;
    if (exprType !== sym.type) {
      this.error(`Type mismatch in assignment to '${name}': expected '${sym.type}', got '${exprType}'`, node.id);
    }
  }

  lookupSymbol(name) {
    for (let i = this.scopes.length - 1; i >= 0; i--) {
      if (this.scopes[i].has(name)) return this.scopes[i].get(name);
    }
    return null;
  }

  checkExpression(expr) {
    if (!expr) return null;
    switch (expr.type) {
      case 'Literal':
        if (expr.value.type === 'NUMBER') return 'number';
        if (expr.value.type === 'STRING') return 'string';
        if (expr.value.type === 'ID') {
          const sym = this.lookupSymbol(expr.value.value);
          if (!sym) {
            this.error(`Undeclared variable '${expr.value.value}'`, expr.value);
            return null;
          }
          return sym.type;
        }
        return null;
      case 'BinaryExpr':
        const leftType = this.checkExpression(expr.left);
        const rightType = this.checkExpression(expr.right);
        if (!leftType || !rightType) return null;
        if (leftType !== rightType) {
          this.error(`Type mismatch in binary operation: '${leftType}' vs '${rightType}'`, expr.operator);
          return null;
        }
        if (['+', '-', '*', '/'].includes(expr.operator.value)) {
          if (leftType !== 'number') {
            this.error(`Operator '${expr.operator.value}' requires number operands, found '${leftType}'`, expr.operator);
            return null;
          }
          return 'number';
        }
        return leftType;
      default:
        this.error(`Unsupported expression type '${expr.type}'`, expr);
        return null;
    }
  }

  checkControl(node) {
    const condType = this.checkExpression(node.condition);
    if (!condType) return;
    // Assume 'number' and 'boolean' are valid boolean-compatible types
    if (condType !== 'number' && condType !== 'boolean') {
      this.error(`Condition in control statement must be boolean-compatible, found '${condType}'`, node.keyword);
    }

    // Also check all statements in body recursively
    for (const stmt of node.body) {
      this.visit(stmt);
    }
  }

  error(msg, node) {
    this.errors.push({
      message: msg,
      line: node?.line || 0,
      col: node?.col || 0
    });
  }
}

// ---------------- INTERMEDIATE CODE GENERATION ---------------- //
class IntermediateCodeGenerator {
  constructor(ast, symbolTable) {
    this.ast = ast;
    this.symbolTable = symbolTable;
    this.tempCounter = 0;
    this.labelCounter = 0;
    this.code = [];
  }

  generateTemp() {
    return `t${this.tempCounter++}`;
  }

  generateLabel() {
    return `L${this.labelCounter++}`;
  }

  generate() {
    for (const node of this.ast) {
      this.visit(node);
    }
    return this.code;
  }

  visit(node) {
    if (!node) return null;

    switch (node.type) {
      case 'Declaration':
        return this.handleDeclaration(node);
      case 'Assignment':
        return this.handleAssignment(node);
      case 'ExprStatement':
        return this.handleExpression(node.expression);
      case 'Control':
        return this.handleControl(node);
      case 'BinaryExpr':
        return this.handleBinaryExpression(node);
      case 'Literal':
        return this.handleLiteral(node);
      default:
        throw new Error(`Unknown node type: ${node.type}`);
    }
  }

  handleDeclaration(node) {
    const name = node.id.value;
    const type = node.valueType.value;
    this.code.push(`DECLARE ${name} : ${type}`);
    return name;
  }

  handleAssignment(node) {
    const target = node.id.value;
    const value = this.visit(node.expression);
    this.code.push(`${target} := ${value}`);
    return target;
  }

  handleBinaryExpression(node) {
    const left = this.visit(node.left);
    const right = this.visit(node.right);
    const temp = this.generateTemp();
    
    if (node.operator.type === 'COMPARE') {
      this.code.push(`${temp} := ${left} ${node.operator.value} ${right}`);
    } else {
      this.code.push(`${temp} := ${left} ${node.operator.value} ${right}`);
    }
    return temp;
  }

  handleLiteral(node) {
    return node.value.value;
  }

  handleControl(node) {
    const label = this.generateLabel();
    const endLabel = this.generateLabel();
    
    switch (node.keyword.value) {
      case 'cycle':
        this.code.push(`${label}:`);
        const condition = this.visit(node.condition);
        this.code.push(`IF ${condition} GOTO ${endLabel}`);
        for (const stmt of node.body) {
          this.visit(stmt);
        }
        this.code.push(`GOTO ${label}`);
        this.code.push(`${endLabel}:`);
        break;
      // Add other control structures as needed
    }
  }
}

// ---------------- CODE OPTIMIZATION ---------------- //
class CodeOptimizer {
  constructor(intermediateCode) {
    this.code = intermediateCode;
    this.optimizedCode = [];
  }

  optimize() {
    this.constantFolding();
    this.algebraicSimplification();
    this.commonSubexpressionElimination();
    this.deadCodeElimination();
    return this.optimizedCode;
  }

  constantFolding() {
    for (const line of this.code) {
      if (line.includes('+') || line.includes('-') || line.includes('*') || line.includes('/')) {
        const [target, expr] = line.split(' := ');
        if (this.isConstantExpression(expr)) {
          const result = this.evaluateConstantExpression(expr);
          this.optimizedCode.push(`${target} := ${result}`);
        } else {
          this.optimizedCode.push(line);
        }
      } else {
        this.optimizedCode.push(line);
      }
    }
  }

  isConstantExpression(expr) {
    return /^\d+(\s*[\+\-\*\/]\s*\d+)*$/.test(expr);
  }

  evaluateConstantExpression(expr) {
    return eval(expr);
  }

  algebraicSimplification() {
    const simplified = [];
    for (const line of this.optimizedCode) {
      if (line.includes(' := ')) {
        let [target, expr] = line.split(' := ');
        // x * 1 → x
        expr = expr.replace(/\s*\*\s*1\b/g, '');
        // x + 0 → x
        expr = expr.replace(/\s*\+\s*0\b/g, '');
        // x - 0 → x
        expr = expr.replace(/\s*-\s*0\b/g, '');
        simplified.push(`${target} := ${expr}`);
      } else {
        simplified.push(line);
      }
    }
    this.optimizedCode = simplified;
  }

  commonSubexpressionElimination() {
    const expressions = new Map();
    const optimized = [];
    
    for (const line of this.optimizedCode) {
      const [target, expr] = line.split(' := ');
      if (expressions.has(expr)) {
        optimized.push(`${target} := ${expressions.get(expr)}`);
      } else {
        expressions.set(expr, target);
        optimized.push(line);
      }
    }
    
    this.optimizedCode = optimized;
  }

  deadCodeElimination() {
    const usedVars = new Set();
    const optimized = [];
    
    // First pass: collect used variables
    for (const line of this.optimizedCode) {
      if (line.startsWith('IF') || line.startsWith('GOTO')) {
        const vars = line.match(/[a-zA-Z_][a-zA-Z0-9_]*/g) || [];
        vars.forEach(v => usedVars.add(v));
      }
    }
    
    // Second pass: keep only used assignments
    for (const line of this.optimizedCode) {
      if (line.startsWith('IF') || line.startsWith('GOTO')) {
        optimized.push(line);
      } else {
        const [target] = line.split(' := ');
        if (usedVars.has(target)) {
          optimized.push(line);
        }
      }
    }
    
    this.optimizedCode = optimized;
  }
}

// ---------------- TARGET CODE GENERATION ---------------- //
class TargetCodeGenerator {
  constructor(optimizedCode) {
    this.code = optimizedCode;
    this.targetCode = [];
    this.registers = new Map();
    this.nextRegister = 0;
  }

  generate() {
    for (const line of this.code) {
      this.translateLine(line);
    }
    return this.targetCode;
  }

  translateLine(line) {
    if (line.startsWith('DECLARE')) {
      this.handleDeclaration(line);
    } else if (line.includes(' := ')) {
      this.handleAssignment(line);
    } else if (line.startsWith('IF')) {
      this.handleConditional(line);
    } else if (line.startsWith('GOTO')) {
      this.handleGoto(line);
    }
  }

  handleDeclaration(line) {
    const [_, name, type] = line.match(/DECLARE (\w+) : (\w+)/);
    this.targetCode.push(`# Declare ${name} as ${type}`);
  }

  handleAssignment(line) {
    const [target, expr] = line.split(' := ');
    const resultReg = this.allocateRegister();
    
    if (this.isConstant(expr)) {
      this.targetCode.push(`LOAD ${resultReg}, ${expr}`);
    } else if (expr.includes('+')) {
      const [left, right] = expr.split(' + ');
      const leftReg = this.allocateRegister();
      const rightReg = this.allocateRegister();
      
      this.targetCode.push(`LOAD ${leftReg}, ${left}`);
      this.targetCode.push(`LOAD ${rightReg}, ${right}`);
      this.targetCode.push(`ADD ${resultReg}, ${leftReg}, ${rightReg}`);
    } else if (expr.includes('-')) {
      const [left, right] = expr.split(' - ');
      const leftReg = this.allocateRegister();
      const rightReg = this.allocateRegister();
      
      this.targetCode.push(`LOAD ${leftReg}, ${left}`);
      this.targetCode.push(`LOAD ${rightReg}, ${right}`);
      this.targetCode.push(`SUB ${resultReg}, ${leftReg}, ${rightReg}`);
    }
    
    this.targetCode.push(`STORE ${resultReg}, ${target}`);
  }

  handleConditional(line) {
    const [_, condition, label] = line.match(/IF (.*) GOTO (.*)/);
    const condReg = this.allocateRegister();
    
    if (condition.includes('>')) {
      const [left, right] = condition.split(' > ');
      const leftReg = this.allocateRegister();
      const rightReg = this.allocateRegister();
      
      this.targetCode.push(`LOAD ${leftReg}, ${left}`);
      this.targetCode.push(`LOAD ${rightReg}, ${right}`);
      this.targetCode.push(`CMP ${leftReg}, ${rightReg}`);
      this.targetCode.push(`JG ${label}`);
    }
  }

  handleGoto(line) {
    const [_, label] = line.match(/GOTO (.*)/);
    this.targetCode.push(`JMP ${label}`);
  }

  allocateRegister() {
    const reg = `R${this.nextRegister++}`;
    this.registers.set(reg, true);
    return reg;
  }

  isConstant(expr) {
    return /^\d+$/.test(expr);
  }
}

// Update the analyzeCode function to include backend phases
function analyzeCode() {
  const code = document.getElementById('codeInput').value;
  const lexicalBox = document.getElementById('lexicalOutput');
  const syntaxBox = document.getElementById('syntaxOutput');
  const semanticBox = document.getElementById('semanticOutput');
  const icgBox = document.getElementById('icgOutput');
  const optimizedBox = document.getElementById('optimizedOutput');
  const targetBox = document.getElementById('targetOutput');

  // Lexical Analysis
  const tokens = tokenize(code);
  let lexOutput = '';
  for (const t of tokens) {
    lexOutput += `TOKEN: ${t.value} \tTYPE: ${t.type} \t[Line: ${t.line}, Col: ${t.col}]\n`;
  }
  lexicalBox.textContent = lexOutput || 'No tokens found.';

  // Syntax Analysis
  const parser = new Parser(tokens);
  const ast = parser.parse();
  if (parser.errors.length > 0) {
    let errOutput = '--- Syntax Errors ---\n';
    for (const err of parser.errors) {
      errOutput += `Error at Line ${err.line}, Col ${err.col}: ${err.message}\n`;
    }
    syntaxBox.textContent = errOutput;
    return;
  }
  syntaxBox.textContent = '--- Syntax Analysis ---\nParsing completed successfully.\n\n--- AST ---\n' + JSON.stringify(ast, null, 2);

  // Semantic Analysis
  const semanticAnalyzer = new SemanticAnalyzer(ast);
  semanticAnalyzer.analyze();
  if (semanticAnalyzer.errors.length > 0) {
    let semOutput = '--- Semantic Errors ---\n';
    for (const err of semanticAnalyzer.errors) {
      semOutput += `Error at Line ${err.line}, Col ${err.col}: ${err.message}\n`;
    }
    semanticBox.textContent = semOutput;
    return;
  }
  semanticBox.textContent = 'Semantic analysis completed successfully.\n\nSymbol Table:\n' +
    JSON.stringify([...semanticAnalyzer.globalScope.entries()], null, 2);

  // Intermediate Code Generation
  const icg = new IntermediateCodeGenerator(ast, semanticAnalyzer.globalScope);
  const intermediateCode = icg.generate();
  icgBox.textContent = '--- Intermediate Code ---\n' + intermediateCode.join('\n');

  // Code Optimization
  const optimizer = new CodeOptimizer(intermediateCode);
  const optimizedCode = optimizer.optimize();
  optimizedBox.textContent = '--- Optimized Code ---\n' + optimizedCode.join('\n');

  // Target Code Generation
  const targetGen = new TargetCodeGenerator(optimizedCode);
  const targetCode = targetGen.generate();
  targetBox.textContent = '--- Target Code ---\n' + targetCode.join('\n');
}
