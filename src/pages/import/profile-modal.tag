profile-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Сохранить профиль загрузки?
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group
                    label.control-label Наименование
                    input.form-control(name='profileName', value='{ item.profileName }')
                    .help-block { error.profileName }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = opts.item

            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                profileName: 'empty'
            }

            modal.afterChange = e => {
                let name = e.target.name
                delete modal.error[name]
                modal.error = {
                    ...modal.error,
                    ...modal.validation.validate(
                        modal.item,
                        modal.rules,
                        name
                    )
                }
            }
        })