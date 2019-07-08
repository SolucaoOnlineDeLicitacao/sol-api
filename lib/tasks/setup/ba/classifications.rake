namespace :setup do
  namespace :classifications do
    namespace :ba do
      desc 'Create default classifications'
      task load: :environment do |task|

        CLASSIFICATIONS = [
          ["Bens", 1, nil],
          ["Serviços", 2, nil],
          ["Obras", 3, nil],
          ["Material de Construção", 100, 1],
          ["Eletrônicos", 101, 1],
          ["Civil", 200, 3],
          ["Elétrica", 201, 3],
          ["Material Elétrico", 102, 1],
          ["Informática", 103, 1],
          ["Comunicação e Telecomunicação", 104, 1],
          ["Áudio, vídeo, foto e telefonia", 105, 1],
          ["Música", 106, 1],
          ["Material pedagógico", 107, 1],
          ["Papelaria", 108, 1],
          ["Jardinagem", 109, 1],
          ["Esportes", 110, 1],
          ["Acampamento", 111, 1],
          ["Máquinas agrícolas", 112, 1],
          ["Agroindústria", 113, 1],
          ["Veículos pesados", 114, 1],
          ["Veículos leves", 115, 1],
          ["Eletrodoméstico", 116, 1],
          ["Vestuário", 117, 1],
          ["Equipamento de proteção individual", 118, 1],
          ["Hidráulica", 202, 3],
          ["Sanitária", 203, 3],
          ["Jardinagem", 300, 2],
          ["Pintura", 301, 2],
          ["Cursos de capacitação", 302, 2],
          ["Tradução", 303, 2],
          ["Limpeza", 304, 2],
          ["Perfuração de Poços", 305, 2],
          ["Topografia e estudos geotécnicos", 306, 2],
          ["Instalação elétrica e hidráulica", 307, 2],
          ["Transporte", 308, 2],
          ["Marketing", 309, 2],
          ["Contabilidade", 310, 2],
          ["Combustível", 311, 1],
          ["Refeição", 312, 1]
        ].freeze

        CLASSIFICATIONS.each do |data|
          Classification.find_or_create_by!(code: data[1]) do |classification|
            classification.name = data[0]
            classification.classification = Classification.find_by(code: data[2]) if data[2].present?
          end
        end
      end
    end
  end
end
