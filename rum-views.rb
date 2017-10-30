# coding: utf-8

class RUM
  module Views
    class Layout < Mustache
      def title
        @title || "Revista de la Universidad de México"
      end

      def og_title
        "Revista de la Universidad de México"
      end

      def og_description
        "---"
      end

      def og_image
        "https://www.revistadelauniversidad.mx/images/rum-u-black.png"
      end

      def og_type
        "website"
      end

      def keywords
        @keywords ?
          @keywords.join(',')  :
          nil
      end

      def current_release
        $db_current_release.call
      end

      def is_in_current_release
        if @article and $db_current_release.call
          @release[:id] == $db_current_release.call[:id]
        end
      end
    end

    class Index < Layout
      def og_title
        "Inicio - Revista de la Universidad de México"
      end

      def og_description
        cr = $db_current_release.call
        "Número Actual: #{cr[:name]} - #{cr[:month_year]} "
      end

      def index
        true
      end
    end

    class Article < Layout
      def og_description
        if @article[:subtitle] and (@article[:subtitle].strip != "")
          @article[:subtitle]

        elsif @article[:quote] and (@article[:quote].strip != "")
          @article[:quote]

        else
          "#{@release[:name]} - #{@release[:month_year]}"
        end
      end

      def og_image
        if @article[:cover] and (@article[:cover].strip != "")
          "https://www.revistadelauniversidad.mx" + @article[:cover]
        else
          "https://www.revistadelauniversidad.mx/images/rum-u-black.png"
        end
      end

      def og_type
        "article"
      end
    end

    class Release < Layout
      def og_description
        "#{@release[:name]} - #{@release[:month_year]} "
      end

      def og_image
        if @release[:cover] and (@release[:cover].strip != "")
          "https://www.revistadelauniversidad.mx" + @release[:cover]
        else
          "https://www.revistadelauniversidad.mx/images/rum-u-black.png"
        end
      end

      def og_type
        "book"
      end
    end

    class Collab < Layout
      def og_description
        @collab[:name]
      end

      def og_image
        if @collab[:metadata][:image] and (@collab[:metadata][:image].strip != "")
          "https://www.revistadelauniversidad.mx" + @collab[:metadata][:image]
        else
          "https://www.revistadelauniversidad.mx/images/rum-u-black.png"
        end
      end

      def og_type
        "profile"
      end
    end
  end
end
