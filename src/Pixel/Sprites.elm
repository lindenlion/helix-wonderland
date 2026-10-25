module Pixel.Sprites exposing (alice, aliceStepping, goldenKey, tart, whiteRabbit)

{-| The game's characters and props. Original pixel art, in the spirit of the
1865 book rather than any film.
-}

import Pixel.Sprite as Sprite exposing (Sprite)


alicePalette : List ( Char, String )
alicePalette =
    [ ( 'k', "#1a1020" ) -- headband, eyes, shoes
    , ( 'y', "#f2d16b" ) -- hair
    , ( 'Y', "#c99a3b" ) -- hair shadow
    , ( 's', "#f6c9a6" ) -- skin
    , ( 'p', "#e88aa8" ) -- mouth
    , ( 'b', "#6fa8dc" ) -- dress
    , ( 'B', "#3d6fa8" ) -- dress hem
    , ( 'w', "#f4f0ff" ) -- apron
    ]


aliceUpperBody : List String
aliceUpperBody =
    [ "....kkkk...."
    , "...yyyyyy..."
    , "..yyyyyyyy.."
    , "..yssssssy.."
    , "..ysksskys.."
    , "..yssssssy.."
    , "..yYsppsYy.."
    , "...bbwwbb..."
    , "..bbbwwbbb.."
    , ".sbbwwwwbbs."
    , ".s.bwwwwb.s."
    , "...bwwwwb..."
    , "..bbwwwwbb.."
    , "..BBBBBBBB.."
    ]


alice : Sprite
alice =
    Sprite.fromRows alicePalette
        (aliceUpperBody
            ++ [ "....s..s...."
               , "....k..k...."
               ]
        )


{-| Second walking frame: legs apart.
-}
aliceStepping : Sprite
aliceStepping =
    Sprite.fromRows alicePalette
        (aliceUpperBody
            ++ [ "...s....s..."
               , "...k....k..."
               ]
        )


whiteRabbit : Sprite
whiteRabbit =
    Sprite.fromRows
        [ ( 'w', "#f4f0ff" ) -- fur
        , ( 'p', "#f4a6c0" ) -- inner ears, nose
        , ( 'k', "#ff5d8f" ) -- pink eyes, as in the book
        , ( 'r', "#c8344e" ) -- waistcoat
        , ( 'y', "#efba5d" ) -- pocket watch
        ]
        [ "...ww..ww..."
        , "...wp..wp..."
        , "...wp..wp..."
        , "...ww..ww..."
        , "..wwwwwwww.."
        , "..wkwwwwkw.."
        , "..wwwppwww.."
        , "...wwwwww..."
        , "..rrrrrrrr.."
        , ".wrrryyrrrw."
        , ".w.rrrrrr.w."
        , "...rrrrrr..."
        , "...wwwwww..."
        , "...ww..ww..."
        , "...ww..ww..."
        , "..www..www.."
        ]


goldenKey : Sprite
goldenKey =
    Sprite.fromRows [ ( 'y', "#efba5d" ) ]
        [ ".yy......."
        , "y..yyyyyyy"
        , ".yy....y.y"
        ]


{-| The Queen of Hearts' tarts are the game's stars: up to three per chapter.
-}
tart : Sprite
tart =
    Sprite.fromRows
        [ ( 'c', "#d9a05b" ), ( 'j', "#c8344e" ), ( 'w', "#ffb3c1" ), ( 'C', "#9c6a32" ) ]
        [ "..cccccc.."
        , ".cjjjjjjc."
        , "cjjwjjjjjc"
        , "cjjjjjjjjc"
        , "cccccccccc"
        , ".CCCCCCCC."
        ]
