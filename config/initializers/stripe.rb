Rails.configuration.stripe = {
    :publishable_key => Settings.stripe.publishable_key,
    :secret_key      => Settings.stripe.secret_key
}

Stripe.api_key = Settings.stripe.secret_key
Stripe.api_version = '2015-10-12' #Making sure the API version used is compatible.