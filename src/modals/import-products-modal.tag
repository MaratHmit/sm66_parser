import-products-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Импорт
        #{'yield'}(to="body")
            loader(text='Импорт', indeterminate='true', if='{ loader }')
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.filename }')
                    .input-group
                        span.input-group-addon.btn-file.btn.btn-default(onchange='{ changeFile }')
                            input(name='file', type='file', , accept='.csv,.xml')
                            i.fa.fa-fw.fa-folder-open
                        input.form-control(name='filename', value='{ item.filename }', placeholder='Выберите файл или введите ссылку',
                        disabled='{ file.files.length }')
                        span.input-group-addon.btn-file.btn.btn-default(onclick='{ clear }', title='Сброс')
                            i.fa.fa-fw.fa-close
                    .help-block { error.filename }
                .form-group
                    label.control-label Тип импорта
                    br
                    label.radio-inline
                        input(type='radio', name='type', value='0', checked='{ item.type == 0 }')
                        | Обновление
                    label.radio-inline
                        input(type='radio', name='type', value='1', checked='{ item.type == 1 }')
                        | Вставка
                .form-group(if='{ item.type == 1 }')
                    .checkbox-inline
                        label
                            input(name='reset', type='checkbox', checked='{ item.reset }')
                            | Очистить базу данных перед импортом
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed', disabled='{ cannotBeClosed }') Закрыть
            button(onclick='{ parent.submit }', type='button', class='btn btn-primary btn-embossed', disabled='{ cannotBeClosed }') Импорт

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.error = false
            modal.mixin('validation')
            modal.mixin('change')
            modal.item = {
                filename: '',
                type: '0',
                reset: false,
            }

            modal.rules = {
                filename: {
                    required: true,
                    rules:[{
                        type: 'url',
                        prompt: 'Выберите файл или введите правильную ссылку',
                    }]
                }
            }

            modal.loader = false
            modal.changeFile = e => {
                modal.item.filename = e.target.files[0].name
                modal.update()
            }

            modal.clear = () => {
                modal.item.filename = ''
                modal.item.file = ''
                modal.file.value = ''
            }

            modal.afterChange = e => {
                if (modal.file.files && !modal.file.files.length) {
                    let name = e.target.name
                    delete modal.error[name]
                    modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
                }

                if (modal.file.files && modal.file.files.length)
                    modal.error = false

                if (modal.item && modal.item.type == 0)
                    modal.item.reset = false

                delete modal.item.file
            }
        })

        self.submit = () => {
            let modal = self.tags['bs-modal']
            let formData = new FormData()
            let target = modal.file

            formData.append('type', modal.item.type)
            formData.append('reset', modal.item.reset)

            if (target.files.length) {
                for (var i = 0; i < target.files.length; i++) {
                   formData.append('file' + i, target.files[i], target.files[i].name)
                }
            } else {
                formData.append('url', modal.item.filename)
                modal.error = modal.validation.validate(modal.item, modal.rules)
                if (modal.error) return
            }

            modal.loader = true
            modal.cannotBeClosed = true
            modal.update()

            API.upload({
                object: 'Product',
                data: formData,
                success(response) {
                    observable.trigger('products-reload')
                    observable.trigger('categories-reload')
                    observable.trigger('special-reload')
                },
                complete() {
                    modal.loader = false
                    modal.cannotBeClosed = false
                    modal.update()
                }
            })

        }
