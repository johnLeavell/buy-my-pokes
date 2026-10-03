# Buy My Pokes

A small Rails storefront for selling Pokémon cards, with user accounts (Devise),
an admin-managed product catalog, a session-based shopping cart, and checkout
via Stripe Checkout.

## Requirements

* Ruby (see `.ruby-version`)
* PostgreSQL
* A [Stripe](https://stripe.com) account (test mode is fine for local dev)

## Setup

```bash
bundle install
bin/rails db:setup   # creates the db, loads the schema, runs db/seeds.rb
```

`db:setup` seeds a handful of sample products. In development it also creates
an admin user: `admin@example.com` / `password123`.

## Environment variables

Set these in a `.env` file (loaded via `dotenv-rails`) or your shell:

| Variable                | Purpose                                                        |
| ------------------------ | --------------------------------------------------------------- |
| `STRIPE_SECRET_KEY`      | Stripe secret API key, used to create checkout sessions.       |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key (reserved for future client-side use).  |
| `STRIPE_WEBHOOK_SECRET`  | Signing secret for the `/webhooks/stripe` endpoint.             |

To test webhooks locally, use the [Stripe CLI](https://stripe.com/docs/stripe-cli):

```bash
stripe listen --forward-to localhost:3000/webhooks/stripe
```

That command prints a webhook signing secret to use as `STRIPE_WEBHOOK_SECRET`.

## Running the app

```bash
bin/rails server
```

Visit `http://localhost:3000`. Sign up for an account, or sign in as the seeded
admin to manage products at `/products/new`.

## Running tests

```bash
bin/rails test
```

## How checkout works

1. Signed-in or anonymous users add products to a session-based cart
   (`/products/:id/add_to_cart`).
2. `/cart` shows the cart and totals; checkout requires signing in.
3. `/checkout/create` builds a Stripe Checkout Session directly from the cart
   contents (no separate Stripe product/price catalog to keep in sync) and
   redirects to Stripe's hosted checkout page.
4. On completion, Stripe calls `/webhooks/stripe`, which records an `Order`
   and its `OrderItem`s and bumps each product's `sales_count`. This webhook
   is the source of truth for orders — the `/checkout/success` page just
   clears the local cart for a good user experience.
5. Users can review their past orders at `/orders`.

## Admin

Product management (`new`/`create`/`edit`/`update`/`destroy`) is restricted
to users with `admin: true`. Grant admin from the console:

```ruby
User.find_by(email: "someone@example.com").update!(admin: true)
```
