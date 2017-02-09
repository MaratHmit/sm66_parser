var changeMixin = {
    change(e) {
        if (!e.target && !e.target.name) return

        if (typeof this.beforeChange === 'function')
            this.beforeChange(e)
        
        var bannedTypes = ['checkbox', 'file', 'color', 'range', 'number', 'radio']

        if (e.target && bannedTypes.indexOf(e.target.type) === -1) {
            var selectionStart = e.target.selectionStart
            var selectionEnd = e.target.selectionEnd
        }

        if (e.target && e.target.type === 'checkbox' && e.target.name) {
            let bool = e.target.getAttribute('data-bool')
            if (!bool)
                this.item[e.target.name] = e.target.checked
            else
                this.item[e.target.name] = e.target.checked ? bool.split(',')[0] : bool.split(',')[1]
        }

        if (e.target && e.target.type !== 'checkbox' && e.target.name)
            this.item[e.target.name] = e.target.value
        if (e.currentTarget.tagName !== 'FORM' && e.currentTarget.name !== '')
            this.item[e.currentTarget.name] = e.currentTarget.value

        if (e.target && bannedTypes.indexOf(e.target.type) === -1) {
            this.update()
            e.target.selectionStart = selectionStart
            e.target.selectionEnd = selectionEnd
        }

        if (typeof this.afterChange === 'function')
            this.afterChange(e)
    }
}

riot.mixin('change', changeMixin)

var removeMixin = {
    remove(e, items, tag) {
        var self = this,
            params = {ids: items}

        modals.create('bs-alert', {
            type: 'modal-danger',
            title: 'Предупреждение',
            text: items.length > 1
                ? 'Вы точно хотите удалить эти записи?'
                : 'Вы точно хотите удалить эту запись?',
            size: 'modal-sm',
            buttons: [
                {action: 'yes', title: 'Удалить', style: 'btn-danger'},
                {action: 'no', title: 'Отмена', style: 'btn-default'},
            ],
            callback(action) {
                if (action === 'yes') {
                    API.request({
                        object: self.collection,
                        method: 'Delete',
                        data: params,
                        success(response) {
                            popups.create({title: 'Успешно удалено!', style: 'popup-success'})
                            tag.reload()
                        }
                    })
                }
                this.modalHide()
            }
        })
    }
}

riot.mixin('remove', removeMixin)