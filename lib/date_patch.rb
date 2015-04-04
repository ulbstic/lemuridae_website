# http://redmine.ruby-lang.org/issues/5270
# workaround for https://github.com/ddfreyne/nanoc/issues/39

if Config::CONFIG["ruby_version"] == "1.8"
  
  class Date
    def self.parse(str='-4712-01-01', comp=false, sg=ITALY)
      elem = _parse(str, comp)
      new_by_frags(elem, sg)
    end

    class << self

      def once(*meths)
        meths.each do |meth|
          # Alias
          orig_meth = '__nonmemoized_' + meth.to_s
          alias_method orig_meth, meth

          # Redefine
          define_method(meth) do |*args|
            # Get cache
            @__memoization_cache ||= {}
            @__memoization_cache[meth] ||= {}

            # Recalculate or fetch
            cache = @__memoization_cache[meth]
            if !cache.has_key?(args)
              cache[args] = send(orig_meth, *args)
            else
              result = cache[args]
            end
          end
        end
      end

      private :once

    end

    # Using one of the factory methods such as Date::civil is
    # generally easier and safer.
    def initialize(ajd=0, of=0, sg=ITALY)
      @ajd, @of, @sg = ajd, of, sg
      @__memoization_cache = {}
    end

    # Get the date as an Astronomical Julian Day Number.
    def ajd() @ajd end

    # Get the date as an Astronomical Modified Julian Day Number.
    def amjd() self.class.ajd_to_amjd(@ajd) end

    once :amjd

    # Get the date as a Julian Day Number.
    def jd() self.class.ajd_to_jd(@ajd, @of)[0] end

    # Get any fractional day part of the date.
    def day_fraction() self.class.ajd_to_jd(@ajd, @of)[1] end

    # Get the date as a Modified Julian Day Number.
    def mjd() self.class.jd_to_mjd(jd) end

    # Get the date as the number of days since the Day of Calendar
    # Reform (in Italy and the Catholic countries).
    def ld() self.class.jd_to_ld(jd) end

    once :jd, :day_fraction, :mjd, :ld

    # Get the date as a Civil Date, [year, month, day_of_month]
    def civil() self.class.jd_to_civil(jd, @sg) end # :nodoc:

    # Get the date as an Ordinal Date, [year, day_of_year]
    def ordinal() self.class.jd_to_ordinal(jd, @sg) end # :nodoc:

    # Get the date as a Commercial Date, [year, week_of_year, day_of_week]
    def commercial() self.class.jd_to_commercial(jd, @sg) end # :nodoc:
  end
end
