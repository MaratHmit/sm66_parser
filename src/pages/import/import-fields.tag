import-fields
    .row(each="{ parent.item.cols }")
        .col-md-3: .form-group
            label.control-label { title }
        .col-md-9: .form-group
            select.selectpicker.form-control(data-id='{ id }', value="{ code }", onchange="{ selectField }")
                option(value="")
                optgroup(each="{ fields }", label="{ title }")
                    option(each="{ items }", value='{ name }', selected='{ name == code }') { title }
            | Пример данных:
            nbsp
            b { sample }
    .row
        .col-md-3: .form-group
            button.btn.btn-danger(onclick='{ parent.back }', type='button') Назад
            button.btn.btn-primary(onclick='{ parent.setSettings }', type='button') Далее

    script(type='text/babel').
        var self = this

        self.selectField = (e) => {
            let id = e.target.dataset.id
            self.parent.item.cols[id].code = e.target.value
        }