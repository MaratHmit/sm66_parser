| import 'select2/dist/js/select2.full'
| import 'select2/dist/css/select2.css'
| import 'select2-bootstrap-theme/dist/select2-bootstrap.css'

select-two

	select

	script(type='text/babel').
		var self = this

		self.one('updated', () => {
			$(self.root).find('select').select2({
				theme: "bootstrap",
			})
		})