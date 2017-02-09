let observable = riot.observable()

if (process.env.NODE_ENV === 'development')
    window.observable = observable

module.exports = observable

if (module.hot)
    module.hot.accept()

