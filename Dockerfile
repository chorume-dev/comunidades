FROM ruby:3.1.6-slim

# Instala pacotes necessários
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    postgresql-client \
    nodejs \
    curl \
    libvips \
    pkg-config \
    dos2unix && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos de dependências
COPY Gemfile Gemfile.lock ./

# Instala as gems
RUN bundle install

# Copia o código-fonte
COPY . .

# Corrige finais de linha Windows (CRLF) para Unix (LF)
RUN dos2unix entrypoint.sh && \
    dos2unix bin/* && \
    find . -name "*.rb" -type f -exec dos2unix {} \; && \
    chmod +x entrypoint.sh bin/*

# Cria diretórios necessários
RUN mkdir -p tmp/pids

# Expõe a porta 3000
EXPOSE 3000

# Define o comando de entrada
CMD ["bash", "./entrypoint.sh"]
