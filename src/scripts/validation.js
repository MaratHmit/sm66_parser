var validation = {
    regExp: {
        bracket : /\[(.*)\]/i,
        decimal : /^\d*(\.)\d+/,
        email   : /^[a-z0-9!#$%&'*+\/=?^_`{|}~.-]+@[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$/i,
        escape  : /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g,
        flags   : /^\/(.*)\/(.*)?/,
        integer : /^\-?\d+$/,
        number  : /^\-?\d*(\.\d+)?$/,
        url     : /(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})/i
    },

    prompt: {
        empty                : 'Поле не должно быть пустым',
        checked              : 'Флажок должен быть включен',
        email                : 'Введите правильный e-mail',
        url                  : 'Введите правильную ссылку',
        regExp               : ' ',
        integer              : 'Поле должно быть целым числом',
        decimal              : 'Поле должно быть вещественным числом',
        number               : 'Поле должно быть числом',
        is                   : 'Поле должно быть "{ruleValue}"',
        isExactly            : 'Поле должно быть "{ruleValue}"',
        not                  : 'Поле не должно быть "{ruleValue}"',
        notExactly           : 'Поле не должно быть "{ruleValue}"',
        contain              : 'Поле должно содержать "{ruleValue}"',
        containExactly       : 'Поле должно содержать "{ruleValue}"',
        doesntContain        : 'Поле не должно содержать "{ruleValue}"',
        doesntContainExactly : 'Поле не должно содержать "{ruleValue}"',
        minLength            : 'Поле должно быть не менее {ruleValue} символов',
        maxLength            : 'Поле должно быть не более {ruleValue} символов',
        match                : ' ',
        different            : ' ',
        minCount             : ' ',
        maxCount             : ' '
    },

    bracketedRule(rule) {
        return (rule.type && rule.type.match(this.regExp.bracket))
    },

    ancillaryValue(rule) {
        if (!rule.type || !this.bracketedRule(rule)) {
            return false
        }
        return rule.type.match(this.regExp.bracket)[1] + ''
    },

    ruleName(rule) {
        if (this.bracketedRule(rule)) {
            return rule.type.replace(rule.type.match(this.regExp.bracket)[0], '')
        }
        return rule.type
    },

    rules: {
        empty(value) {
            return !(value === undefined || '' === value || Array.isArray(value) && value.length === 0)
        },

        // checkbox checked
        checked(value) {
            return value
        },

        // is most likely an email
        email(value) {
            return this.regExp.email.test(value)
        },

        // value is most likely url
        url(value) {
            return this.regExp.url.test(value)
        },

        regExp(value, regExp) {
            var regExpParts = regExp.match(this.regExp.flags),
                flags
            // regular expression specified as /baz/gi (flags)
            if(regExpParts) {
                regExp = (regExpParts.length >= 2)
                    ? regExpParts[1]
                    : regExp
                flags = (regExpParts.length >= 3)
                    ? regExpParts[2]
                    : ''
            }
            return value.match( new RegExp(regExp, flags) )
        },

        // is valid integer or matches range
        integer(value, range) {
            var intRegExp = this.regExp.integer,
                min,
                max,
                parts

            if( !range || ['', '..'].indexOf(range) !== -1) {
                // do nothing
            }
            else if(range.indexOf('..') == -1) {
                if(intRegExp.test(range))
                    min = max = range - 0
            } else {
                parts = range.split('..', 2)
                if(intRegExp.test(parts[0]))
                    min = parts[0] - 0
                if(intRegExp.test(parts[1]))
                    max = parts[1] - 0
            }
            return (
                intRegExp.test(value) &&
                (min === undefined || value >= min) &&
                (max === undefined || value <= max)
            )
        },

        decimal(value) {
            return this.regExp.decimal.test(value);
        },

        // is valid number
        number(value) {
            return this.regExp.number.test(value);
        },

        // is value (case insensitive)
        is(value, text) {
            text = (typeof text == 'string')
                ? text.toLowerCase()
                : text
            value = (typeof value == 'string')
                ? value.toLowerCase()
                : value
            return (value == text)
        },

        // is value
        isExactly(value, text) {
            return (value == text)
        },

        // value is not another value (case insensitive)
        not(value, notValue) {
            value = (typeof value == 'string')
                ? value.toLowerCase()
                : value
            notValue = (typeof notValue == 'string')
                ? notValue.toLowerCase()
                : notValue
            return (value != notValue)
        },

        // value is not another value (case sensitive)
        notExactly(value, notValue) {
            return (value != notValue)
        },

        // value contains text (insensitive)
        contains(value, text) {
            text = text.replace(this.regExp.escape, "\\$&")
            return (value.search( new RegExp(text, 'i') ) !== -1)
        },

        // value contains text (case sensitive)
        containsExactly(value, text) {
            text = text.replace(this.regExp.escape, "\\$&")
            return (value.search( new RegExp(text) ) !== -1)
        },

        // value contains text (insensitive)
        doesntContain(value, text) {
            text = text.replace(this.regExp.escape, "\\$&");
            return (value.search( new RegExp(text, 'i') ) === -1);
        },

        // value contains text (case sensitive)
        doesntContainExactly(value, text) {
            text = text.replace(this.regExp.escape, "\\$&");
            return (value.search( new RegExp(text) ) === -1);
        },

        match(value, identifier) {
            return (identifier !== undefined)
                ? value.toString() === identifier.toString()
                : false
        },

        // different than another field
        different(value, identifier) {
            return (identifier !== undefined)
                ? value.toString() !== identifier.toString()
                : false
        },

        minLength(value, requiredLength) {
            return (value !== undefined)
                ? (value.length >= requiredLength)
                : false
        },

        // is less than length
        maxLength(value, maxLength) {
            return (value !== undefined)
                ? (value.length <= maxLength)
                : false
        },

        minCount(value, minCount) {
            if(minCount == 0)
                return true
            if(minCount == 1)
                return (value !== '')
            return (value.split(',').length >= minCount)
        },

        maxCount(value, maxCount) {
            if(maxCount == 0)
                return false
            if(maxCount == 1)
                return (value.search(',') === -1)
            return (value.split(',').length <= maxCount)
        },
    },

    validateRule(value, rule, item) {
        let result
        let ruleValue = ''
        let ruleName = this.ruleName(rule)
        let prompt = this.prompt[ruleName]

        if (this.rules.hasOwnProperty(ruleName) &&
            typeof this.rules[ruleName] === 'function') {

            if (this.bracketedRule(rule)) {
                if (['match', 'different'].indexOf(ruleName) === -1) {
                    ruleValue = this.ancillaryValue(rule)
                    result = this.rules[ruleName].bind(this)(value, ruleValue)
                } else {
                    ruleValue = item[this.ancillaryValue(rule)]
                    result = this.rules[ruleName].bind(this)(value, ruleValue)
                }
            } else {
                result = this.rules[ruleName].bind(this)(value)
            }

            if(!result) {
                return (rule.prompt || prompt).replace('{ruleValue}', ruleValue)
            } else {
                return undefined
            }
        }
    },

    validateRules(value, ruleValues, item) {
        let prompt

        if (typeof ruleValues === 'string')
            prompt = this.validateRule(value, {type: ruleValues}, item)

        if (ruleValues instanceof Array && Array.isArray(ruleValues)) {
            for (let i = 0; i < ruleValues.length; i++) {
                let rule = ruleValues[i]

                if (typeof rule === 'string')
                    prompt = this.validateRule(value, {type: rule}, item)

                if (typeof rule === 'object' && !Array.isArray(rule))
                    prompt = this.validateRule(value, rule, item)

                if (prompt)
                    break
            }
        }

        if (typeof ruleValues === 'object' && !Array.isArray(ruleValues)) {
            let required = ruleValues.hasOwnProperty('required') ? ruleValues.required : false
            let rules = ruleValues.rules || []

            if (!required && value === '') {
                return
            }

            if (Array.isArray(rules)) {
                for (let i = 0; i < rules.length; i++) {
                    let rule = rules[i]

                    if (typeof rule === 'string')
                        prompt = this.validateRule(value, {type: rule}, item)

                    if (typeof rule === 'object' && !Array.isArray(rule))
                        prompt = this.validateRule(value, rule, item)

                    if (prompt)
                        break
                }
            }
        }
        return prompt
    },

    validate(item, fields, fieldName) {
        let result = {}
        let prompt

        if (typeof fieldName === 'string' && fieldName !== '') {
            let ruleValues = fields[fieldName]
            let value = item[fieldName] || ''
            prompt = this.validateRules(value, ruleValues, item)
            if (prompt) result[fieldName] = prompt
        } else {
            for (var field in fields) {
                let ruleValues = fields[field]
                let value = item[field] || ''
                prompt = this.validateRules(value, ruleValues, item)
                if (prompt) result[field] = prompt
            }
        }

        return Object.keys(result).length ? result : false
    }
}

module.export = validation

var validationMixin = {
    validation: validation
}

riot.mixin('validation', validationMixin)