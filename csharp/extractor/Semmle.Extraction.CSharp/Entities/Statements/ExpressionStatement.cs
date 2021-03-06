using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace Semmle.Extraction.CSharp.Entities.Statements
{
    class ExpressionStatement : Statement<ExpressionStatementSyntax>
    {
        ExpressionStatement(Context cx, ExpressionStatementSyntax node, IStatementParentEntity parent, int child)
            : base(cx, node, Kinds.StmtKind.EXPR, parent, child) { }

        public static ExpressionStatement Create(Context cx, ExpressionStatementSyntax node, IStatementParentEntity parent, int child)
        {
            var ret = new ExpressionStatement(cx, node, parent, child);
            ret.TryPopulate();
            return ret;
        }

        protected override void Populate()
        {
            if (Stmt.Expression != null)
                Expression.Create(cx, Stmt.Expression, this, 0);
            else
                cx.ModelError(Stmt, "Invalid expression statement");
        }
    }
}
