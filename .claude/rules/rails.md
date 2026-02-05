# rails

Rails-specific guidance

## Important rules

- **Never create foreign key constraints** - no `foreign_key: true`, no `add_foreign_key`
- When adding a FK column to an existing table, use `add_reference` instead of `add_column` + `add_index`
- Inside `create_table` blocks, `t.belongs_to` and `t.references` are equivalent - both are fine
- Limit migration files to changing a single table when possible
- When changing multiple columns on a single table, use `change_table` with `bulk: true`

## New files

- Use `rails generate` commands where possible
- When creating migrations, use `rails generate migration` e.g. `rails generate migration add_favorite_number_to_users favorite_number:integer`
  - This will create
  ```ruby
  # db/migrate/20260116170237_add_favorite_number_to_users.rb
  class AddFavoriteNumberToUsers < ActiveRecord::Migration[6.1]
    def change
      add_column :users, :favorite_number, :integer
    end
  end
  ```

- When creating models, use `rails generate model` e.g. `rails generate model Post title author:belongs_to interactions:integer`
  - This will create
  ```ruby
  # db/migrate/20260116170345_create_posts.rb
  class CreatePosts < ActiveRecord::Migration[6.1]
    def change
      create_table :posts do |t|
        t.string :title
        t.belongs_to :author, foreign_key: true
        t.integer :interactions

        t.timestamps
      end
    end
  end

  # app/models/post.rb
  class Post < ApplicationRecord
    belongs_to :author
  end

  # and various test files
  ```

- When creating full CRUD for a new model, use `rails generate scaffold` e.g. `rails generate scaffold Post title author:belongs_to interactions:integer`
  - This creates the above files as well as views for the `Post` model, updating `config/routes.rb`, and
  ```ruby
  # app/controllers/posts_controller.rb

  class PostsController < ApplicationController
    before_action :set_post, only: %i[ show edit update destroy ]

    # GET /posts or /posts.json
    def index
      @posts = Post.all
    end

    # GET /posts/1 or /posts/1.json
    def show
    end

    # GET /posts/new
    def new
      @post = Post.new
    end

    # GET /posts/1/edit
    def edit
    end

    # POST /posts or /posts.json
    def create
      @post = Post.new(post_params)

      respond_to do |format|
        if @post.save
          format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
          format.json { render :show, status: :created, location: @post }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /posts/1 or /posts/1.json
    def update
      respond_to do |format|
        if @post.update(post_params)
          format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
          format.json { render :show, status: :ok, location: @post }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /posts/1 or /posts/1.json
    def destroy
      @post.destroy

      respond_to do |format|
        format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_post
        @post = Post.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def post_params
        params.require(:post).permit(:title, :author_id, :interactions)
      end
  end
  ```
- You'll need to remove `foreign_key: true` for any `rails generate`d migrations

## Database Commands

> [!WARNING]
> You should not run these. They are listed just for illustrative purposes

```bash
rails db:migrate
rails db:seed
rails db:reset
```

## Database styles

- Text columns should use `limit: 4_294_967_295` (MySQL LONGTEXT)

## HAML styles

- Do **NOT** create new `.html.haml` files. Editing existing haml files is fine but new files should be `.html.erb`

## ERB styles

- All partials: `render({ partial: 'path/to/partial', locals: { key: value }})`. Not `render 'path/to/partial', key: value`
- All partials should live in a `partials` folder inside their resource e.g. `claims/sop_workflow/partials/_intake.html.erb`
- Don't add unnecessary HTML classes or IDs. If you don't use, or don't plan to use, the class or ID, don't add it

## Rails controller styles

- Don't use `redirect_to(... notice: '...')`. Instead: `flash[:success] = '...'` then `redirect_to(...)`
- Don't use `redirect_to(...) and return`. Instead: `redirect_to(...)` then `return`

## Rails view styles

- Give form helper block arguments better names: `form_with ... do |form|` not `do |f|`

## Configuration

**master.key** (CRITICAL):
- Required for credentials decryption
- Obtain from AWS SSM Parameter Store (search for project's `MASTER_KEY` parameter)
- Place in `config/master.key` with no trailing newline
- Never commit to version control

**Environment Variables**:
- `.env` file for local port configuration
- Key vars: APP_ENV_VARS


- Don't use a `form.number_field` for a dollar amount or percentage. Instead, use `bulma_money_field` with `field_opts: { data: { money_preset: :money } }` or `field_opts: { data: { money_preset: :percent } }`, respectively
  - Check `app/javascript/controllers/money_field_controller.ts` for available `money_preset` options
  - Anything needing to override the preset should go in `money_options`
- Don't use a `form.check_box`. Instead, use `bulma_checkbox`
- Don't use a `form.text_field`. Instead, use `bulma_text_field`
- Don't use a `form.text_area`. Instead, use `bulma_textarea`
- Don't use a `form.date_field`. Instead, use `bulma_date_field`
- Don't manually build a `<select>` tag with `<option>`s. Instead, use `bulma_select` and `options_for_select` or `options_from_collection_for_select`
- Don't use a `form.select`. Instead, use `bulma_select`
- Don't use a `form.submit`. Instead, use `bulma_button` with `type: :submit`
- Don't use `<button>`, use `bulma_button` instead
- When using `bulma_button`, you don't need to specify `type: :button` as that is the default
- Don't use `link_to`, use `bulma_link` instead where possible
- When using `bulma_link`, don't add the `is-link` class; it gets added already
- When using `bulma_link`, don't add the `is-inverted` class; use `inverted: true` instead
- Don't use `number_to_currency`/`number_to_percentage` → use `number_to_money`/`number_to_percent`
