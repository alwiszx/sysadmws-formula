pkg:
  docker-ce:
    when: 'PKG_BEFORE_DEPLOY'
    states:
      - file.directory:
          1:
            - name: /etc/docker
            - mode: 700
      - file.managed:
          1:
            - name: /etc/docker/daemon.json
            - contents: |
                { "iptables": false, "default-address-pools": [ {"base": "172.16.0.0/12", "size": 24} ] }
{%- if grains["os"] == "CentOS" %}
      - file.managed:
          1:
            - name: /etc/yum.repos.d/docker-ce.repo
            - source:
              - https://download.docker.com/linux/centos/docker-ce.repo
            - skip_verify: True
{%- else %}
      - pkgrepo.managed:
          1:
            - humanname: Docker CE Repository
            - name: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ grains['oscodename'] }} stable
            - file: /etc/apt/sources.list.d/docker-ce.list
            - key_url: https://download.docker.com/linux/ubuntu/gpg
{%- endif %}
      - pkg.latest:
          1:
            - refresh: True
            - pkgs:
              - docker-ce
              - python3-docker
      - service.running:
          1:
            - name: docker
      - cmd.run:
          1:
            - name: systemctl restart docker
            - onchanges:
                - file: /etc/docker/daemon.json
