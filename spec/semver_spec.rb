require 'semver'
require 'tempfile'

describe SemVer do

  it "should compare against another version versions" do
    semvers = [
      SemVer.new(0, 1, 0),
      SemVer.new(0, 1, 1),
      SemVer.new(0, 2, 0),
      SemVer.new(1, 0, 0)
    ]
    (semvers.size - 1).times do |n|
      semvers[n].should < semvers[n+1]
    end
  end

  it "should serialize to and from a file" do
    tf = Tempfile.new 'semver.spec'
    path = tf.path
    tf.close!

    v1 = SemVer.new 1,10,33
    v1.save path
    v2 = SemVer.new
    v2.load path

    v1.should == v2
  end

  it "should find an ancestral .semver" do
    found = SemVer.find
    found.should_not be_nil
  end

  API = %W[special patch minor major load save format to_s <=>].collect(&:to_sym)
  API.each { |x|
    it "should quack like a SemVer class" do
      sv = SemVer.new
      sv.should respond_to(x)
    end
  }
  
  # Semantic Versioning 2.0.0-rc.1
  
  it "should format with fields" do
    v = SemVer.new 10, 33, 4, 'beta'
    v.format("v%M.%m.%p%s").should == "v10.33.4-beta"
  end

  it "should to_s with dash" do
    v = SemVer.new 4,5,63, 'alpha.45'
    v.to_s.should == 'v4.5.63-alpha.45'
  end
  
  it "should format with dash" do
    v = SemVer.new 2,5,11,'a.5'
    v.format("%M.%m.%p%s").should == '2.5.11-a.5'
  end
  
  it "should not format with dash if no special" do
    v = SemVer.new 2,5,11
    v.format("%M.%m.%p%s").should == "2.5.11"
  end
  
  it "should not to_s with dash if no special" do
    v = SemVer.new 2,5,11
    v.to_s.should == "v2.5.11"
  end
  
  it "should behave like the readme says" do
    v = SemVer.new(0,0,0)
    v.major                     # => "0"
    v.major += 1
    v.major                     # => "1"
    v.special = 'alpha.46'
    v.format "%M.%m.%p%s"       # => "1.1.0-alpha.46"
    v.to_s                      # => "v1.1.0"
  end


  it "should parse formats correctly" do
    semver_strs = [
      'v1.2.3',
      'v1.2.3',
      '0.10.100-b32',
      'version:3-0-45',
      '3$2^1',
      '3$2^1-bla567',
    ]

    formats = [
      nil,
      SemVer::TAG_FORMAT,
      '%M.%m.%p%s',
      'version:%M-%m-%p',
      '%M$%m^%p',
      '%M$%m^%p%s',
    ]

    semvers= [
      SemVer.new(1, 2, 3),
      SemVer.new(1, 2, 3),
      SemVer.new(0, 10, 100, 'b32'),
      SemVer.new(3, 0, 45),
      SemVer.new(3, 2, 1),
      SemVer.new(3, 2, 1, 'bla567'),
    ]

    semver_strs.zip(formats, semvers).each do |args|
      str, format, semver = args
      SemVer.parse(str, format).should eq(semver)
    end
  end

  it "should only allow missing version parts when allow_missing is set" do
    semver_strs = [
      'v1',
      'v1',
      'v1',

      'v1.2',
      'v1.2',

      nil,
    ]

    formats = [
      'v%M',
      'v%m',
      'v%p',

      'v%M.%m',
      'v%m.%p',

      nil,
    ]

    semvers= [
      SemVer.new(1, 0, 0),
      SemVer.new(0, 1, 0),
      SemVer.new(0, 0, 1),

      SemVer.new(1, 2, 0),
      SemVer.new(0, 1, 2),

      nil,
    ]

    semver_strs.zip(formats, semvers).each do |args|
      str, format, semver = args

      SemVer.parse(str, format).should eq(semver)
      SemVer.parse(str, format, true).should eq(semver)

      SemVer.parse(str, format, false).should be_nil
    end
  end
  
  
  
  
  # Semantic Versioning 2.0.0-rc2
  
  it "aliases #prerelease to #special" do
    v1 = SemVer.new
    v1.special = 'foo'
    v1.prerelease.should == 'foo'
    v2 = SemVer.new
    v2.prerelease = 'bar'
    v2.special.should == 'bar'
  end
  
  it "should compare again another SemVer by prerelease" do
    pres = %w( alpha alpha.1 beta.2 beta.3 beta.11 rc.1 )
    semvers = pres.map do |pre|
      SemVer.new 1, 0, 0, pre
    end
    (semvers.size - 1).times do |n|
      semvers[n].should < semvers[n+1]
    end
    semvers.reverse!
    (semvers.size - 1).times do |n|
      semvers[n].should > semvers[n+1]
    end
  end
  
  it "should compare a SemVer with prerelease against a SemVer without prerelease" do
    v1 = SemVer.new(1, 0, 0, 'foo')
    v2 = SemVer.new(1, 0, 0)
    v1.should < v2
    v2.should > v1
    v1.should == v1
  end

end
