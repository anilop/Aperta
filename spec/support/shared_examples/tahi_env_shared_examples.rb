shared_examples_for 'required env var' do |var:|
  describe "Required env var: #{var}" do
    it 'is required to be set' do
      ClimateControl.modify valid_env.merge("#{var}": nil) do
        expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set, but was not.")
      end
    end

    it 'is required to have a value' do
      ClimateControl.modify valid_env.merge("#{var}": '') do
        expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to have a value, but was set to nothing.")
      end
    end

    it 'shows up in the list of known about env vars' do
      expect(TahiEnv.registered_env_vars[var.to_s]).to eq(
        TahiEnv::RequiredEnvVar.new(var)
      )
    end
  end

  reader_method_name = "#{var.downcase}"
  describe "TahiEnv.#{reader_method_name}" do
    it "returns the value stored in the env var when set" do
      ClimateControl.modify valid_env.merge("#{var}": 'ABC') do
        expect(TahiEnv.send(reader_method_name)).to eq 'ABC'
      end
    end

    it "returns nil when not set" do
      ClimateControl.modify valid_env.merge("#{var}": nil) do
        expect(TahiEnv.send(reader_method_name)).to be nil
      end
    end
  end
end

shared_examples_for 'dependent required env var' do |var:, dependent_key:|
  describe "Dependent required env var: #{var}" do
    it 'is not required to be set when dependent key is false' do
      ClimateControl.modify valid_env.merge("#{var}": nil, "#{dependent_key}": 'false') do
        expect(env.errors.full_messages.join).to_not match("Environment Variable: #{var} was expected")
      end
    end

    it 'is required to be set when dependent key is true' do
      ClimateControl.modify valid_env.merge("#{var}": nil, "#{dependent_key}": 'true') do
        expect(env.errors.full_messages.join).to match("Environment Variable: #{var} was expected")
      end
    end

    it 'is required to have a value when dependent key is true' do
      ClimateControl.modify valid_env.merge("#{var}": '', "#{dependent_key}": 'true') do
        expect(env.errors.full_messages.join).to match("Environment Variable: #{var} was expected")
      end
    end

    it 'shows up in the list of known about env vars' do
      expect(TahiEnv.registered_env_vars[var.to_s]).to eq(
        TahiEnv::RequiredEnvVar.new(var)
      )
    end
  end
end

shared_examples_for 'dependent required boolean env var' do |var:, dependent_key:|
  describe "Dependent required booelan env var: #{var}" do
    include_examples 'dependent required env var', var: var, dependent_key: dependent_key

    describe 'dependent_key is true' do
      around do |example|
        # Use merge! so valid_env is modified since we want to run all
        # subsequent examples with the dependent_key set to a value
        ClimateControl.modify valid_env.merge!("#{dependent_key}": 'true') do
          example.run
        end
      end

      include_examples 'required boolean env var', var: var
    end
  end
end

shared_examples_for 'optional env var' do |var:|
  describe "Optional env var: #{var}" do
    it 'is does not need to be set' do
      ClimateControl.modify valid_env.merge("#{var}": nil) do
        expect(env.valid?).to be true
      end
    end

    it 'shows up in the list of known about env vars' do
      expect(TahiEnv.registered_env_vars[var.to_s]).to eq(
        TahiEnv::OptionalEnvVar.new(var)
      )
    end
  end

  reader_method_name = "#{var.downcase}"
  describe "TahiEnv.#{reader_method_name}" do
    it "returns the value stored in the env var when set" do
      ClimateControl.modify valid_env.merge("#{var}": 'ABC') do
        expect(TahiEnv.send(reader_method_name)).to eq 'ABC'
      end
    end

    it "returns nil when not set" do
      ClimateControl.modify valid_env.merge("#{var}": nil) do
        expect(TahiEnv.send(reader_method_name)).to be nil
      end
    end
  end
end

shared_examples_for 'required boolean env var' do |var:|
  describe "Required boolean env var: #{var}" do
    it 'shows up in the list of known about env vars' do
      expect(TahiEnv.registered_env_vars[var.to_s]).to eq(
        TahiEnv::RequiredEnvVar.new(var)
      )
    end

    query_method_name = "#{var.downcase}?"
    describe "TahiEnv.#{query_method_name}" do
      it "is required to be set" do
        ClimateControl.modify valid_env.merge("#{var}": nil) do
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set to a boolean, but was not set. Allowed boolean values are true (true, 1), or false (false, 0).")
        end
      end

      it "is required to a boolean value" do
        ClimateControl.modify valid_env.merge("#{var}": '') do
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set to a boolean value, but was set to \"\". Allowed boolean values are true (true, 1), or false (false, 0).")
        end

        ClimateControl.modify valid_env.merge("#{var}": 'a string value') do
          env.valid?
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set to a boolean value, but was set to \"a string value\". Allowed boolean values are true (true, 1), or false (false, 0).")
        end
      end

      it "returns true when set to 'true' or '1'" do
        ClimateControl.modify valid_env.merge("#{var}": 'true') do
          expect(TahiEnv.send(query_method_name)).to be true
        end

        ClimateControl.modify valid_env.merge("#{var}": '1') do
          expect(TahiEnv.send(query_method_name)).to be true
        end
      end

      it "returns false when set to 'false' or '0'" do
        ClimateControl.modify valid_env.merge("#{var}": 'false') do
          expect(TahiEnv.send(query_method_name)).to be false
        end

        ClimateControl.modify valid_env.merge("#{var}": '0') do
          expect(TahiEnv.send(query_method_name)).to be false
        end
      end
    end
  end
end

shared_examples_for 'optional boolean env var' do |var:, default_value:|
  describe "Optional boolean env var: #{var}" do
    it 'is does not need to be set' do
      ClimateControl.modify valid_env.merge("#{var}": nil) do
        expect(env.valid?).to be true
      end
    end

    it 'shows up in the list of known about env vars' do
      expect(TahiEnv.registered_env_vars[var.to_s]).to eq(
        TahiEnv::OptionalEnvVar.new(var)
      )
    end

    query_method_name = "#{var.downcase}?"
    describe "TahiEnv.#{query_method_name}" do
      it "defaults to #{default_value} when not set" do
        ClimateControl.modify valid_env.merge("#{var}": nil) do
          expect(TahiEnv.send(query_method_name)).to be default_value
        end
      end

      it "returns true when set to 'true' or '1'" do
        ClimateControl.modify valid_env.merge("#{var}": 'true') do
          expect(TahiEnv.send(query_method_name)).to be true
        end

        ClimateControl.modify valid_env.merge("#{var}": '1') do
          expect(TahiEnv.send(query_method_name)).to be true
        end
      end

      it "returns false when set to 'false' or '0'" do
        ClimateControl.modify valid_env.merge("#{var}": 'false') do
          expect(TahiEnv.send(query_method_name)).to be false
        end

        ClimateControl.modify valid_env.merge("#{var}": '0') do
          expect(TahiEnv.send(query_method_name)).to be false
        end
      end
    end
  end
end
