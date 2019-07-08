#
# Extensões para a classe Array
#
module CoreExtensions
  module Array

    #
    # Retorna uma cópia de self sem os elementos com os valores definidos por values.
    #
    # usage:
    #   %i[requested scheduled done canceled].except(:requested) # === %i[scheduled done canceled]
    #   [1, 2, 1, 3, 1].except(1) # === [2, 3]
    #
    def except(*values)
      self - values
    end

    #
    # Remove os elementos com os valores definidos por values, alterando a instância "in-place".
    #
    def except!(*values)
      values.each { |value| delete(value) }
    end
  end
end

Array.send :include, CoreExtensions::Array
