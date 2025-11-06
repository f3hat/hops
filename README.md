# hops

**hops** é uma ferramenta simples de inspeção de rede escrita em Bash.
Ela resolve endereços IPv4/IPv6, realiza consultas de rDNS (PTR), lista nameservers (NS) e traça saltos de rede com informações de ASN e organização via dig, traceroute, whois e Team Cymru.

## Recursos

- Resolução de IPv4 e IPv6
- Consulta de rDNS (PTR)
- Listagem de nameservers (NS) com IP e ASN
- Traceroute com enriquecimento de ASN/organização
- Saída colorida (True Color 24-bit) e legível em terminal
- Exportação em JSON para integração com outros sistemas (e.g., jq)
- Licenciado sob GPLv3+

## Instalação

### Instalação padrão
```
sudo make install
```

Instala:
- Binário: `/usr/local/bin/hops`
- Manpage: `/usr/local/share/man/man1/hops.1`

### Instalação personalizada
```
make install PREFIX=/opt/hops
```

### Para empacotamento
```
make install DESTDIR=./pkg
```

## Dependências

`hops` depende das seguintes ferramentas já presentes em sistemas Unix-like:

- dig
- traceroute
- whois
- awk, grep, timeout (utilitários básicos)

Verifique com:
```
make check
```

## Uso

```
hops [opção] <domínio>
```

### Opções
- -d       → Mostrar IPv4 e IPv6
- -d4      → Mostrar apenas IPv4
- -d6      → Mostrar apenas IPv6
- -ns      → Mostrar nameservers
- -a       → Mostrar hops (traceroute)
- -ptr     → Mostrar DNS reverso (PTR)
- -json    → Saída em JSON
- -v       → Mostrar versão
- -h       → Mostrar ajuda

### Exemplos
```
hops example.com
hops -d example.com
hops -ns example.com
hops -json example.com
```

## Empacotamento

Gerar tarball e checksum (SHA-256):
```
make dist
```

Isso cria:
- hops-vX.X.X.tar.gz
- hops-vX.X.X.tar.gz.sha256

Verificar integridade:
```
make verify
```

## Documentação

Manpage disponível:
```
man hops
```

## Licença

Distribuído sob a GNU General Public License v3 ou posterior (GPLv3+).

Veja o arquivo COPYING ou acesse: https://www.gnu.org/licenses/gpl-3.0.html

## Contribuições

Pull requests são bem-vindos!
Para mudanças maiores, abra uma issue primeiro para discutir o que você gostaria de modificar.
