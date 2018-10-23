#=
NOTE: TOKENS must be single-char characters, for safety, that means they are
composed of chars before code-point 80. So not things like ∀ or ∃ etc.
=#

"""
    MD_1C_TOKENS

Dictionary of single-char tokens for Markdown. Note that these characters are
exclusive, they cannot appear again in a larger token.
"""
const MD_1C_TOKENS = Dict{Char, Symbol}(
    '{'  => :LXB_OPEN,
    '}'  => :LXB_CLOSE,
    '\n' => :LINE_RETURN)


"""
    MD_TOKENS_LX

Subset of `MD_1C_TOKENS` with only the latex tokens (for parsing what's in a math environment).
"""
const MD_1C_TOKENS_LX = Dict{Char, Symbol}(
    '{'  => :LXB_OPEN,
    '}'  => :LXB_CLOSE)


"""
    MD_TOKENS

Dictionary of tokens for Markdown. Note that for each, there may be several
possibilities to consider in which case the order is important: the first
case that works will be taken.
"""
const MD_TOKENS = Dict{Char, Vector{Pair{Tuple{Int, Bool, Function}, Symbol}}}(
    '<' => [ isexactly("<!--") => :COMMENT_OPEN ],   # <!-- ...
    '-' => [ isexactly("-->")  => :COMMENT_CLOSE ],  #      ... -->
    '~' => [ isexactly("~~~")  => :ESCAPE ],         # ~~~  ... ~~~
    '\\' => [
        isexactly("\\{")  => :INACTIVE,              # See note [^1]
        isexactly("\\}")  => :INACTIVE,              # See note [^1]
        isexactly("\\\$") => :INACTIVE,              # See note [^1]
        isexactly("\\[")  => :MATH_C_OPEN,           # \[ ...
        isexactly("\\]")  => :MATH_C_CLOSE,          #    ... \]
        isexactly("\\begin{align}")    => :MATH_ALIGN_OPEN,
        isexactly("\\end{align}")      => :MATH_ALIGN_CLOSE,
        isexactly("\\begin{eqnarray}") => :MATH_EQA_OPEN,
        isexactly("\\end{eqnarray}")   => :MATH_EQA_CLOSE,
        isexactly("\\newcommand")      => :LX_NEWCOMMAND,
        incrlook((_, c) -> α(c))       => :LX_COMMAND ], # \command⎵*
    '@' => [
        isexactly("@def", [' ']) => :MD_DEF_OPEN,    # @def var = ...
        isexactly("@@", SPACER)  => :DIV_CLOSE,      # @@⎵*
        incrlook((i, c) ->
            ifelse(i==1, c=='@', α(c, ['-']))) => :DIV_OPEN ], # @@dname
    '$' => [
        isexactly("\$", ['$'], false) => :MATH_A,    # $⎵*
        isexactly("\$\$") => :MATH_B,                # $$⎵*
    ],
    '_' => [
        isexactly("_\$>_") => :MATH_I_OPEN,
        isexactly("_\$<_") => :MATH_I_CLOSE,
    ],
    '`' => [
        isexactly("`", ['`'], false) => :CODE_SINGLE,             # `⎵*
        isexactly("```", SPACER) => :CODE,                        # ```⎵*
        incrlook((i, c) -> i∈[1,2] ? c=='`' : α(c)) => :CODE_L ], # ``lang*
    ) # end dict
#= NOTE
[1] capturing \{ here will force the head to move after it thereby not
marking it as a potential open brace, same for the close brace.
[2] check if these are still useful. =#


"""
    MD_TOKENS_LX

Subset of `MD_TOKENS` with only the latex tokens (for parsing what's in a math
environment).
"""
const MD_TOKENS_LX = Dict{Char, Vector{Pair{Tuple{Int, Bool, Function}, Symbol}}}(
    '\\' => [
        isexactly("\\{")         => :INACTIVE,
        isexactly("\\}")         => :INACTIVE,
        incrlook((_, c) -> α(c)) => :LX_COMMAND ])


"""
    MD_OCB

Dictionary of Open-Close Blocks whose content should be deactivated (any token
within their span should be marked as inactive) until further processing.
The keys are identifier for the type of block, the value is a pair with the
opening and closing tokens followed by a boolean indicating whether the block
is nestable or not.
The only `OCBlock` not in this dictionary is the brace block since it should
not deactivate its content which is needed to find latex definitions (see
parser/markdown/find_blocks/find_md_lxdefs).

Dev note: order matters.
"""
const MD_OCB = [
    # name            opening token    closing token     nestable
    :COMMENT      => ((:COMMENT_OPEN => :COMMENT_CLOSE), false),
    :ESCAPE       => ((:ESCAPE       => :ESCAPE       ), false),
    :CODE_INLINE  => ((:CODE_SINGLE  => :CODE_SINGLE  ), false),
    :CODE_BLOCK_L => ((:CODE_L       => :CODE         ), false),
    :CODE_BLOCK   => ((:CODE         => :CODE         ), false),
    :MD_DEF       => ((:MD_DEF_OPEN  => :LINE_RETURN  ), false), # see [^3]
    :LXB          => ((:LXB_OPEN     => :LXB_CLOSE    ), true ),
    :DIV          => ((:DIV_OPEN     => :DIV_CLOSE    ), true ),
]
#= NOTE:
    [3] an `MD_DEF` goes from an `@def` to the next `\n` so no multiple-line
    def are allowed.
=#


"""
    MD_OCB_MATHS

Same concept as `MD_OCB` but for math blocks, they can't be nested.
Separating them from the other dictionary makes their processing easier.
"""
const MD_OCB_MATHS = [
    :MATH_A     => ((:MATH_A          => :MATH_A          ), false),
    :MATH_B     => ((:MATH_B          => :MATH_B          ), false),
    :MATH_C     => ((:MATH_C_OPEN     => :MATH_C_CLOSE    ), false),
    :MATH_I     => ((:MATH_I_OPEN     => :MATH_I_CLOSE    ), false),
    :MATH_ALIGN => ((:MATH_ALIGN_OPEN => :MATH_ALIGN_CLOSE), false),
    :MATH_EQA   => ((:MATH_EQA_OPEN   => :MATH_EQA_CLOSE  ), false),
]

"""
    MD_OCB_ALL

Combination of all `MD_OCB` in order.

Dev note: the order in which these are stacked matters.
"""
const MD_OCB_ALL = vcat(MD_OCB, MD_OCB_MATHS)


"""
    MD_MATH_NAMES

List of names of maths environments.
"""
const MD_MATHS_NAMES = [e.first for e ∈ MD_OCB_MATHS]


"""
    MD_IGNORE

List of names of blocks that will need to be dropped at compile time.
"""
const MD_IGNORE = [:COMMENT, :MD_DEF]
