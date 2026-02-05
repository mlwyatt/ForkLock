# RSpec

RSpec testing guidance.

**Framework**: RSpec with FactoryBot

## Running Tests

```bash
# Run all tests
rspec

# Run specific test file
rspec spec/path/to/file_spec.rb

# Run specific test by line number
rspec spec/path/to/file_spec.rb:123
```

## Test Organization

- `spec/models/` - Model tests
- `spec/requests/` - Request/API tests
- `spec/system/` - System/feature tests with Capybara + Selenium
- `spec/jobs/` - Background job tests
- `spec/factories/` - FactoryBot factories
- `spec/support/` - Test helpers and shared contexts

## System Tests

- Verify Selenium Grid containers are running:
  `docker compose --profile testing up -d chrome-server --scale chrome-server=4`
- Uses headless Chrome in Docker containers
- VNC access via `vnc-grid.html` for debugging (open outside docker container)
- If I've given you permission to run rspec, still ask about running system tests the first time. I need to verify
  external docker containers are running

## Test Writing Rules

- When writing or editing tests, mark them as `:unverified` - a human must verify the business logic is correct
- When reviewing PRs, flag any `:unverified` tags as needing human verification before merge
- When writing `expect` statements, instead of `expect(claim_equipment.should_be_total_loss?).to(be(true))` use `expect(claim_equipment).to(be_should_be_total_loss)`
- If you get an error using factories, don't change the factory. Look at other spec files for setup examples or ask for help.
- Use `subject` where applicable.
  - Instead of
  ```ruby
  RSpec.describe(ProfileReporterTracker) do
    let(:tracker) { described_class.new }
    let(:other) { NotTheDescribedClass.new }

    it 'is present' do
      expect(tracker).to(be_present)
    end

    it 'is not present' do
      expect(other).to(be_nil)
    end
  end
  ```
  use
  ```ruby
  RSpec.describe(ProfileReporterTracker) do
    subject(:tracker) { described_class.new }

    let(:other) { NotTheDescribedClass.new }

    it { is_expected.to(be_present) }

    it 'is not present' do
      expect(other).to(be_nil)
    end
  end
  ```
- Don't write "change detector" tests, e.g.
  - ```ruby
    RSpec.describe(Reports::ReporterProgress::Report) do
      describe 'STATUSES constant', :unverified do
        it 'contains the expected statuses in order' do
          expect(described_class::STATUSES).to(eq([
            'Not Started',
            'Received',
            'Changes Made',
            'Accounting Completed'
          ]))
        end
      end
    end
    ```
