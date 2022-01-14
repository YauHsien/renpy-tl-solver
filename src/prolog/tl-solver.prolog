tl(File) :-
    csv_read_file(File, Rows, [separator(0),convert(false),match_arity(false)]),
    translate(Rows, Results),
    %
    File1 = File,
    open(File1, write, Fstream, [bom(true)]),
    foreach(member(row(R),Results), writeln(Fstream,R)).

translate(Rows, Results) :-
    translate(Rows, [], Results).

translate([], Acc, Results) :-
    reverse(Acc, Results).
translate([row(Atom)|Rows], Acc, Results) :-
    prog(Atom, Result), !,
    format("~a~n", [Result]),
    translate(Rows, [Result|Acc], Results).
translate(Rows, Acc, Results) :-
    reverse(Acc, R0),
    enfunc(R0, R1),
    append(R1, Rows, Results).

prog(Atom, Result) :-
    atomic_list_concat([A,B], '""', Atom), !,
    prompt1('翻譯：'),
    read_line_to_string(user_input, Input),
    "" \= Input,
    atomic_list_concat([A,'"',Input,'"',B], '', Result).
prog(Atom, Atom).

enfunc([], []).
enfunc([Line|Rows], [row(Line)|Results]) :-
    enfunc(Rows, Results).
