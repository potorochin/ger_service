-module (test).
-export ([xmlToProp/1, findXml/2, checkName/5, convertXml/4, propToXml/2, readAndPars/1]).



readAndPars(FileName) -> 
		{ok, S} = 	file:read_file(FileName),
		xmlToProp(S).


	xmlToProp(Xml) -> 
		Rez = string:split(Xml, "\n", all),

		PreRez = lists:reverse(findXml(Rez, [])),

		%%%%%%%%%%%%%% REZULTAT %%%%%%%%%%%%%%%%%%%
		[convertXml((PreRez), [], [], []) , PreRez].

		%%%%%%%%%%%%%% REZULTAT %%%%%%%%%%%%%%%%%%%
	

	findXml([], Acc) -> Acc;

	findXml([Head | Tail], Acc) -> 
		%io:format("~p~n", [Head]),
		StartPoint = binary:matches(Head, <<"<">>),
		EndPoint = binary:matches(Head, <<">">>),
 
		ListCheck = lists:reverse(checkName(StartPoint, EndPoint, 0, Head, [])),

		findXml(Tail, [ListCheck | Acc]).
%%%%%%%%%
%
%%%%%%%%%
	checkName([],[], _, _, Acc) -> 
	Acc;

	checkName([Head1 | Tail1], [ Head2 | Tail2], BuffPoint, In, Acc) ->

		XmlFind = binary:matches(In, <<"?xml">>),
		DoctypeFind = binary:matches(In, <<"!DOCTYPE">>),

		FinderXml = countList(XmlFind, 0),
		FinderDoc = countList(DoctypeFind, 0),

		case FinderXml of %CHECKER OFF
			1 -> checkName(Tail1, Tail2, 0, In, Acc);
				0 ->

				case FinderDoc of
					1 -> checkName(Tail1, Tail2, 0, In, Acc);
						0 -> 
							{Start, _ } = Head1,
							{End, _ } = Head2,

							case lists:nthtail(1, string:split(In, "/", all)) of
								[<<">">>] -> %%%%% THIS THING
								RezFindHard = findHardTag(string:split(In, " ", all),0,[],[]),
								%io:format("~p~n", [RezFindHard]),
								checkName([], [], [], [], RezFindHard );
								_ -> 

								RezKey =  binary:bin_to_list(In, {Start + 1,End - Start - 1}),
							case BuffPoint > 0 of
								true -> 
								RezInf =  binary:bin_to_list(In, {BuffPoint, Start - BuffPoint  }),
								
								checkName(Tail1, Tail2, End+1, In, [RezInf++RezKey | Acc]);
								
								false ->
								checkName(Tail1, Tail2, End+1, In, [RezKey| Acc])
							end
						end

							
							
					end
		end.

	convertXml([], _, _, Acc) -> Acc;

	convertXml([Head | Tail], Buff, BuffValue, Acc) -> 
		case countList(Head, 0) of	
			1 -> 
				[Tag] = Head,
				case countList(string:split(Tag, "/", all) , 0) of
					1 -> 

						CheckTag = erlang:length(string:split(Tag, " ", all)),
						case CheckTag > 1 of
							%% {"year=\"2000\"","color=\"black\""} %%%

							true -> [ DeleteTag | NeedText] = string:split(Tag, " ", all),
							convertXml(Tail, Buff, [ {erlang:list_to_atom(DeleteTag) , findValue(NeedText, [])} | BuffValue], Acc);
							false -> convertXml(Tail, Buff, BuffValue, Acc)
						end;
						% add tag
					2 -> 
						[_, Tagers] = string:split(Tag, "/", all),

						case is_empty_list(Buff) of
							false -> convertXml(Tail, Buff, BuffValue, {Tagers, Acc});
							true -> 
								case proplists:delete(erlang:list_to_atom(Tagers), BuffValue) == BuffValue of
									false -> 
								convertXml(Tail, 
									[], 
									proplists:delete(erlang:list_to_atom(Tagers), BuffValue),
									[ {erlang:list_to_atom(Tagers), proplists:get_value(erlang:list_to_atom(Tagers), BuffValue),lists:reverse(Buff)} | Acc] );

									true ->
								convertXml(Tail, [],	BuffValue,						 
								[{erlang:list_to_atom(Tagers),lists:reverse(Buff)} | Acc]) %add tag, confirm Acc

						%delete tag/value

								end

					end
						
				end;

			2 ->
				[Tag, Value] = Head, 
				ValueTag = string:split(Value, "/", all),

				case erlang:length(ValueTag) of
					1 -> 

				[[HardTag, HardValue]] = ValueTag,
					convertXml(Tail, [{erlang:list_to_atom(Tag), {erlang:list_to_atom(HardTag), HardValue} }| Buff], BuffValue, Acc);
					2 -> 
				[NeedValue, _] = ValueTag,
				convertXml(Tail, [{erlang:list_to_atom(Tag), NeedValue} | Buff], BuffValue, Acc);
				_ -> convertXml(Tail, Buff, BuffValue, Acc)
			end;
			0 -> convertXml(Tail, Buff, BuffValue, Acc)
		end.

		findValue([], Acc) -> Acc;

		findValue([Head | Tail],  Acc) ->
			
			InputList = (string:split(Head, "\"")),
			[Tag, Value] = InputList,
			findValue(Tail, [
				{erlang:list_to_atom(lists:reverse(lists:nthtail(1, lists:reverse(Tag)))), 
				erlang:list_to_atom(lists:reverse(lists:nthtail(1, lists:reverse(Value))))} | Acc]).


		findHardTag([], _, _, Acc) -> Acc;	

		findHardTag([Head | Tail], Counter, Buff, Acc) ->
			case Counter of
				0 -> 
				case Head == <<>> of
					true -> findHardTag(Tail, 0, Buff, Acc);
					false ->  Tag = Head,
					findHardTag(Tail, 1, Buff, [ lists:nthtail(1, binary_to_list(Tag))| Acc])
				end;

				_ -> 
					case Counter rem 2 of
						1 -> findHardTag(Tail, Counter+1, Head, Acc);
						0 -> 
						%%For Value
						NiceValue =  lists:reverse(lists:nthtail(3, lists:reverse(lists:nthtail(1,binary_to_list(Head))))),

						%% For Tag
						NiceTag = lists:reverse(lists:nthtail(1, lists:reverse(binary_to_list(Buff)))),
						
						findHardTag(Tail, Counter+1, [], 	
							[[NiceTag, NiceValue] | Acc])
					end

			end.

%%%%%%%%%
% COUNTLIST
%%%%%%%%%		

	countList([], Acc) -> Acc;

	countList([_ | Tail], Acc) ->
		countList(Tail, Acc + 1).

%%%%%%%%%
%	EMPTY_LIST
%%%%%%%%%

	is_empty_list([]) -> false;
	is_empty_list(_) -> true.

%%%%%%%%%%
% ADDED LONG STRING
%%%%%%%%%%

	add_long_string([], Acc) -> Acc;

	add_long_string([Head | Tail], Acc) ->
		add_long_string(Tail, string:concat(Acc, Head)).

	propToXml(List, FileName) ->

		{ok, S} = file:open(FileName, write),

		file:write_file(FileName, add_long_string(goFromText(List, []),""), [binary] ),

		file:close(S).


	goFromText([],  Acc)-> 
		lists:reverse(Acc);

	goFromText([Head | Tail], Acc) -> 

	TagValue = string:split(Head, "/", all),

	case  erlang:length(Head) of
		1 -> 
			case erlang:length(string:split(Head, "/", all)) < 3 of
				true -> 
					case erlang:length(string:split(Head, " ", all)) of
						1 -> 	
							[Inf] = Head,
							goFromText(Tail, [add_long_string(["<", Inf, ">", "\n"],"") | Acc]);
						_ -> [ HeadAtribute | TailAtribute] = string:split(Head, " ", all), %%%%%%%% <<<-----
						
						goFromText(Tail, [add_long_string([	
							"<", HeadAtribute, " " , long_atribut(TailAtribute,  ""), " > ", "\n"], "") | Acc])
					end;
				
				false -> goFromText(Tail, Acc)
			end;
		2 -> [Value, Tag] = TagValue,

		case erlang:length(string:split(Head, "/", all)) of
				1 -> goFromText(Tail, Acc);
				2 -> NeedValue = lists:nthtail(erlang:length(Tag), Value),
				goFromText(Tail, [add_long_string(
					["<", Tag, "> ", NeedValue, " </", Tag, "> ", "\n"],"") | Acc])
				
				end;
		_ -> goFromText(Tail, Acc)
	end.

	long_atribut([], Acc) -> Acc;

	long_atribut([Head | Tail],  Acc) -> 

		OutValue = string:split(Head, "\"", all),

		io:format("~p~n", [OutValue]),

		[NiceTag, NiceValue, _] = OutValue,
		long_atribut(Tail, add_long_string([NiceTag, "\"", NiceValue, "\"", " ", Acc], "")).

