/**
 * @name Useless assignment to local variable
 * @description An assignment to a local variable that is not used later on, or whose value is always
 *              overwritten, has no effect.
 * @kind problem
 * @problem.severity warning
 * @id js/useless-assignment-to-local
 * @tags maintainability
 *       external/cwe/cwe-563
 * @precision very-high
 */

import javascript
import DeadStore

/**
 * Holds if `vd` is a definition of variable `v` that is dead, that is,
 * the value it assigns to `v` is not read.
 */
predicate deadStoreOfLocal(VarDef vd, PurelyLocalVariable v) {
  v = vd.getAVariable() and
  exists (vd.getSource()) and
  // the definition is not in dead code
  exists (ReachableBasicBlock rbb | vd = rbb.getANode()) and
  // but it has no associated SSA definition, that is, it is dead
  not exists (SsaExplicitDefinition ssa | ssa.defines(vd, v))
}

from VarDef dead, PurelyLocalVariable v  // captured variables may be read by closures, so don't flag them
where deadStoreOfLocal(dead, v) and
      // the variable should be accessed somewhere; otherwise it will be flagged by UnusedVariable
      exists(v.getAnAccess()) and
      // don't flag ambient variable definitions
      not dead.(ASTNode).isAmbient() and
      // don't flag function expressions
      not exists (FunctionExpr fe | dead = fe.getId()) and
      // don't flag function declarations nested inside blocks or other compound statements;
      // their meaning is only partially specified by the standard
      not exists (FunctionDeclStmt fd, StmtContainer outer |
        dead = fd.getId() and outer = fd.getEnclosingContainer() |
        not fd = outer.getBody().(BlockStmt).getAStmt()
      ) and
      // don't flag overwrites with `null` or `undefined`
      not SyntacticConstants::isNullOrUndefined(dead.getSource()) and
      // don't flag default inits that are later overwritten
      not (isDefaultInit(dead.getSource().(Expr).getUnderlyingValue()) and dead.isOverwritten(v)) and
      // don't flag assignments in externs
      not dead.(ASTNode).inExternsFile() and
      // don't flag exported variables
      not any(ES2015Module m).exportsAs(v, _)
select dead, "This definition of " + v.getName() + " is useless, since its value is never read."
