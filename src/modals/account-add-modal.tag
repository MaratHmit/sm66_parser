| import md5 from 'blueimp-md5/js/md5.min.js'

account-add-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавление аккаунта
        #{'yield'}(to="body")
            form
                .alert.alert-danger(if='{ error }')
                    a.close(href='#', onclick='{ parent.closeErrorAlert.bind(this) }') &times;
                    | Неправильный или неактивный логин или пароль!
                .form-group
                    .input-group
                        span.input-group-addon
                            .fa.fa-cog.fa-fw
                        input.form-control(name='project', placeholder='Проект')
                .form-group
                    .input-group
                        span.input-group-addon
                            .fa.fa-user.fa-fw
                        input.form-control(name='serial', placeholder='Логин')
                .form-group(style='margin-bottom: 0')
                    .input-group
                        span.input-group-addon
                            .fa.fa-key.fa-fw
                        input.form-control(name='password', placeholder='Пароль', type='password')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.closeErrorAlert = function () {
            this.error = false
        }

        self.submit = function () {
            let _this = this
            app.login({
                project: _this.project.value.trim(),
                serial: _this.serial.value.trim(),
                password: md5(_this.password.value.trim()),
                success(response, secookie) {
                    API.request({
                        object: 'Account',
                        method: 'Save',
                        cookie: app.mainCookie,
                        data: {
                            project: _this.project.value.trim(),
                            login: _this.serial.value.trim(),
                            hash: md5(_this.password.value.trim()),
                        },
                        success(response) {
                            observable.trigger('accounts-change', response.items)
                            if (typeof opts.success === 'function')
                                opts.success.bind(this)(response.items)
                            _this.modalHide()
                        },
                        error() {
                            _this.error = true
                            _this.update()
                        }
                    })

                    observable.trigger('accounts-change', response.items)
                    if (typeof opts.success === 'function')
                        opts.success.bind(this)(response.accounts)
                    _this.modalHide()
                },
                error(response) {
                    _this.error = true
                    _this.update()
                }
            })
        }
