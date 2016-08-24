use BindStorage;
role Injected[Str $name] {
	has Bind	$.injected;

	method compose($obj) {
		with $name {
			$!injected = BindStorage.instance.get-bind($obj.WHAT, $name);
		} else {
			$!injected = BindStorage.instance.get-bind($obj.WHAT);
		}
	}
}
