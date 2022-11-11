/** <module> Defines the colors in chess
 *
 *  This module defines predicates representing the side to move or the color of a piece, along with associated predicates.
 *
 *  @author Abhijeet Krishnan
 *  @copyright (c)2022 Abhijeet Krishnan.
 *  @license All rights reserved. Used with permission.
 */

/**
 * color(-Color:color) is semidet
 * 
 * Defines the valid colors (white, black) in chess.
 *
 * @param Color A color in chess
 */
color(white).
color(black).

/**
 * other_color(+Color:color, -OtherColor:color) is semidet
 * 
 * Returns the opposite color.
 *
 * @param Color Input color for which we want to find the opposite color
 * @param OtherColor Output opposite color
 */
other_color(white, black).
other_color(black, white).

/**
 * color_string(+Color:color, -String:str) is det
 * 
 * Produces the string representation of a color for display or for parsing FEN
 * 
 * @param Color The color to be converted to a string
 * @param String The string representation of Color
 */
color_str(white, "w").
color_str(black, "b").