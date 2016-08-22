say "Injected";
role Injected {
	trusts BindStorage;
	has 			$.injected = True;
	has	Bind[Type]	$!bind;
}

