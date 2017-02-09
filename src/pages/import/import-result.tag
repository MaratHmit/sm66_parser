import-result
    | Импорт завершен
    .row
        .col-md-3: .form-group
            label.control-label Успешно импортировано элементов
            input.form-control(name='countSuccess', type='text', value='{ parent.importResult.countSuccess }', readonly='true')
    .row
        .col-md-3: .form-group
            label.control-label Не удалось импортировать
            input.form-control(name='countSuccess', type='text', value='{ parent.importResult.countError }', readonly='true')
    .row
        .col-md-3: .form-group
            button.btn.btn-danger(onclick='{ parent.newImport }', type='button') Новый импорт
            button.btn.btn-primary(onclick='{ parent.catalog }', type='button') Справочник товаров
