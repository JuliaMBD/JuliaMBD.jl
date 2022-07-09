macro define(blk)
    expr = Expr(:block,
        Expr(:call, :eval, Expr(:call, :expr_define_structure, blk)),
        Expr(:call, :eval, Expr(:call, :expr_define_function, blk)),
        Expr(:call, :eval, Expr(:call, :expr_define_next, blk)),
        Expr(:call, :eval, Expr(:call, :expr_define_expr, blk)))
    esc(expr)
end

