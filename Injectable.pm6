say "Injectable";
role Injectable {
	trusts BindStorage;
	has 	$.injectable = True;

	method !create-bind(Str $named?) {
		$!bind .= new: :$named;
		BindStorage.get-instance.add-bind: $!bind
	}
}

