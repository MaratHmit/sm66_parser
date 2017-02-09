| import md5 from 'blueimp-md5/js/md5.min.js'

auth
    .layout
    .container
        .row
            .col-xs-12.col-sm-8.col-sm-offset-2.col-md-6.col-md-offset-3.col-lg-4.col-lg-offset-4
                .auth-logo
                form(onsubmit='{ auth }')
                    .panel.panel-default(style='margin-top: 30px;')
                        .panel-heading.text-center
                            .panel-title Требуется авторизация
                        .panel-body
                            .alert.alert-danger(if='{error}')
                                a.close(href='#', onclick='{ closeErrorAlert }') &times;
                                | Неправильный или неактивный логин или пароль!
                            .form-group
                                .input-group
                                    span.input-group-addon
                                        .fa.fa-user.fa-fw
                                    input.form-control(name='serial', placeholder='Логин')
                            .form-group
                                .input-group
                                    span.input-group-addon
                                        .fa.fa-key.fa-fw
                                    input.form-control(name='password', placeholder='Пароль', type='password')
                            .form-group(style='margin-bottom: 0')
                                .checkbox
                                    label
                                        input(name='remember', type='checkbox')
                                        | Запомнить меня
                        .panel-footer.text-center
                            input.btn.btn-primary(type='submit', value='Продолжить')

    style(scoped).
        .layout {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #333;
            z-index: -1;
        }

    script(type='text/babel').
        var self = this

        self.closeErrorAlert = () => {
            self.error = false
        }

        self.auth = () => {

            app.login({
                //project: self.project.value.trim(),
                serial: self.serial.value.trim(),
                password: md5(self.password.value.trim()),
                success(response, secookie) {
                    if (self.remember.checked)
                        localStorage.setItem('shop24_user', JSON.stringify(response.config))

                    if (response.permissions)
                        localStorage.setItem('shop24_permissions', JSON.stringify(response.permissions))

                    localStorage.setItem('shop24_cookie', secookie)
                    localStorage.setItem('shop24', JSON.stringify(response))
                    app.init()
                },
                error(response) {
                    self.error = true
                    self.update()
                }
            })
        }