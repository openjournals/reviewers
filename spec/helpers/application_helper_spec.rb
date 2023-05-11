describe ApplicationHelper do
  describe "Journal configurable settings" do
    it "By default values are read from settings file" do
      expect(journal_name).to eq("Journal of Open Source Testing Software")
      expect(journal_alias).to eq("JOSTS")
      expect(journal_url).to eq("https://testing.joss.theoj.org")
    end

    it "Values can be overwritten from ENV" do
      ENV["JOURNAL_NAME"] = "Test Journal"
      ENV["JOURNAL_ALIAS"] = "TJ"
      ENV["JOURNAL_URL"] = "https://test_journ.al"

      expect(journal_name).to eq("Test Journal")
      expect(journal_alias).to eq("TJ")
      expect(journal_url).to eq("https://test_journ.al")
    end
  end
end
