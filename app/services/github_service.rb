# frozen_string_literal: true

class GithubService
  REPO = 'chorume-dev/comunidades'
  CACHE_KEY = 'github_contributors_with_merged_prs'
  CACHE_EXPIRY = 1.hour
  REPO_URL = 'https://github.com/chorume-dev/comunidades'

  class << self
    def contributors_with_merged_prs(force_refresh = false)
      Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY, force: force_refresh) do
        fetch_contributors_from_github
      end
    end
    
    def repo_url
      REPO_URL
    end
    
    private
    def fetch_contributors_from_github
      begin
        # Use token de autenticação se disponível para evitar limites de requisição
        client = Octokit::Client.new
        
        # Buscar todos os pull requests fechados e mesclados na branch main
        merged_prs = client.pull_requests(REPO, state: 'closed').select { |pr| pr.merged && pr.base.ref == 'main' }
        
        # Extrair contribuidores únicos
        contributors = merged_prs.map do |pr|
          {
            login: pr.user.login,
            avatar_url: pr.user.avatar_url,
            html_url: pr.user.html_url,
            contributions: merged_prs.count { |p| p.user.login == pr.user.login },
            latest_pr_merged_at: pr.merged_at
          }
        end.uniq { |c| c[:login] }
        
        # Ordenar por número de contribuições (mais contribuições primeiro)
        contributors.sort_by { |c| [-c[:contributions], c[:login]] }
      rescue Octokit::Unauthorized, Octokit::TooManyRequests => e
        # Para repositórios públicos, não precisamos de autenticação,
        # mas podemos atingir limites de requisição não autenticadas (60 por hora)
        Rails.logger.warn("GitHub API rate limiting: #{e.message}")
        []
      rescue Octokit::Error => e
        Rails.logger.error("GitHub API error (#{e.class.name}): #{e.message}")
        []
      end
    end
  end
end