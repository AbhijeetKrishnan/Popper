:- use_module(src/colors).
:- use_module(src/piece_types).
:- use_module(src/squares).
:- use_module(src/pieces).
:- use_module(src/moves).
:- use_module(src/square_set).
:- use_module(src/base_board).
:- use_module(src/board).
:- use_module(src/make_move).
:- use_module(src/tactics).

:- unload_file(debug).
:- unload_file(load).
:- set_prolog_flag(answer_write_options, [max_depth(0)]). % https://stackoverflow.com/a/36948699