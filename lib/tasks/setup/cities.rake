# Download do arquivo em https://www.ibge.gov.br/geociencias/downloads-geociencias.html
# organizacao_do_territorio > estrutura_territorial > areas_territoriais > 2018

namespace :setup do
  namespace :cities do
    desc 'Create initial cities and states'
    task load: :environment do |task|

      # ID;CD_GCUF;NM_UF;NM_UF_SIGLA;CD_GCMUN;NM_MUN_2018;AR_MUN_2018
      CSV.foreach('lib/tasks/setup/AR_BR_MUN_2018.csv', { col_sep: ';', headers: true }) do |row|
        next if row['ID'].blank?

        state = State.find_or_create_by!(code: row['CD_GCUF']) do |state|
          state.attributes = {
            uf: row['NM_UF_SIGLA'],
            name: row['NM_UF']
          }
        end

        City.find_or_create_by!(code: row['CD_GCMUN']) do |city|
          city.attributes = {
            state: state,
            name: row['NM_MUN_2018']
          }
        end
      end
    end
  end
end
