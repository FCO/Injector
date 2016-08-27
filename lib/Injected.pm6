use BindStorage;

#| Role added on parameters that should be injected
role Injected[Str $name #={injector name}] {
	has Bind	$.injected;

	method compose($obj) {
		with $name {
			$!injected = BindStorage.instance.get-bind($obj.WHAT, $name);
		} else {
			$!injected = BindStorage.instance.get-bind($obj.WHAT);
		}
	}
}
