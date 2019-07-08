require 'rails_helper'

RSpec.describe Pdf::Builder::Bidding do
  let(:bidding) { create(:bidding) }
  let(:html) do
    File.open(Rails.root.join("spec/fixtures/myfiles/#{file_type}_template.html")).read
  end
  let(:file_type) { 'edict' }
  let(:params) { { header_resource: bidding, html: html, file_type: file_type } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.html).to eq(html) }
  end

  describe '.call' do
    let(:unix_timestamp) { 1552410032 }
    let(:rand_value) { 12345 }
    let(:filename) { "#{unix_timestamp}_#{rand_value}_#{file_type}.pdf" }
    let(:file_path) { Rails.root.join('storage', filename) }
    let(:file_size) { File.size(file_path) }
    let(:file_exists?) { File.exists?(file_path) }

    before do
      allow(DateTime).to receive(:current).and_return(unix_timestamp)
      allow(Random).to receive(:rand).with(99999).and_return(rand_value)

      subject
    end

    subject { described_class.call(params) }

    context 'without header' do
      let(:params) { { html: html, file_type: file_type } }

      it { expect(subject.path).to eq(file_path.to_s) }
      it { expect(file_exists?).to be_truthy }
      it { expect(file_size).to be > 0 }
    end

    context 'with header' do
      context 'when html is present' do
        context 'and is minute' do
          context 'and bidding is finnished' do
            context 'and is global' do
              let(:file_type) { 'minute_finnished_global' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end

            context 'and is lot' do
              let(:file_type) { 'minute_finnished_lot' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end

            context 'and there are invites' do
              let(:file_type) { 'minute_finnished_invites' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end

            context 'when there are comments' do
              let(:file_type) { 'minute_finnished_comments' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end
          end

          context 'and bidding is failure' do
            context 'and is global' do
              let(:file_type) { 'minute_failure_global' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end

            context 'and is lot' do
              let(:file_type) { 'minute_failure_lot' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end

            context 'and there are invites' do
              let(:file_type) { 'minute_failure_invites' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end

            context 'when there are comments' do
              let(:file_type) { 'minute_failure_comments' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end
          end

          context 'and bidding is desert' do
            context 'and there are not invites' do
              let(:file_type) { 'minute_desert' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end

            context 'and there are invites' do
              let(:file_type) { 'minute_desert_invites' }

              it { expect(subject.path).to eq(file_path.to_s) }
              it { expect(file_exists?).to be_truthy }
              it { expect(file_size).to be > 0 }
            end
          end

          context 'and has addendum' do
            describe 'type 1' do
              context 'and contract is refused' do
                let(:file_type) { 'minute_addendum_refused' }

                it { expect(subject.path).to eq(file_path.to_s) }
                it { expect(file_exists?).to be_truthy }
                it { expect(file_size).to be > 0 }
              end

              context 'and contract is total_inexecution' do
                let(:file_type) { 'minute_addendum_total_inexecution' }

                it { expect(subject.path).to eq(file_path.to_s) }
                it { expect(file_exists?).to be_truthy }
                it { expect(file_size).to be > 0 }
              end
            end

            describe 'type 2' do
              context 'and is global' do
                context 'and contract is refused' do
                  let(:file_type) { 'minute_addendum_accepted_refused' }

                  it { expect(subject.path).to eq(file_path.to_s) }
                  it { expect(file_exists?).to be_truthy }
                  it { expect(file_size).to be > 0 }
                end

                context 'and contract is total_inexecution' do
                  let(:file_type) { 'minute_addendum_accepted_total_inexecution' }

                  it { expect(subject.path).to eq(file_path.to_s) }
                  it { expect(file_exists?).to be_truthy }
                  it { expect(file_size).to be > 0 }
                end
              end

              context 'and is lot' do
                context 'and contract is refused' do
                  let(:file_type) { 'minute_addendum_accepted_refused_lot' }

                  it { expect(subject.path).to eq(file_path.to_s) }
                  it { expect(file_exists?).to be_truthy }
                  it { expect(file_size).to be > 0 }
                end

                context 'and contract is total_inexecution' do
                  let(:file_type) { 'minute_addendum_accepted_total_inexecution_lot' }

                  it { expect(subject.path).to eq(file_path.to_s) }
                  it { expect(file_exists?).to be_truthy }
                  it { expect(file_size).to be > 0 }
                end
              end
            end
          end
        end

        context 'and is edict' do
          let(:file_type) { 'edict' }

          it { expect(subject.path).to eq(file_path.to_s) }
          it { expect(file_exists?).to be_truthy }
          it { expect(file_size).to be > 0 }
        end
      end
    end

    context 'when html is nil' do
      let(:rand_value) { 12346 }
      let(:html) { nil }

      it { is_expected.to be_nil }
      it { expect(file_exists?).to be_falsey }
    end

    context 'when html is blank' do
      let(:rand_value) { 12347 }
      let(:html) { '' }

      it { is_expected.to be_nil }
      it { expect(file_exists?).to be_falsey }
    end
  end
end
