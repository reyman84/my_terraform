**ready-to-use Ansible Interview Q\&A 

## 1. Core Concepts

**Q: What is Ansible and how is it different from Chef/Puppet?
A: Ansible is an agentless configuration management, orchestration, and provisioning tool. It uses SSH or WinRM to communicate with nodes; no agent needs to be installed. Playbooks are in YAML (easy to read). Chef/Puppet are agent-based, use Ruby DSLs, and have steeper learning curves.

**Q: Explain Ansible’s architecture.
A: One control node runs Ansible and pushes configurations to managed nodes over SSH/WinRM. Key components:
– **Inventory**: list of hosts/groups.
– **Modules**: units of work (copy, service, ec2).
– **Plugins**: extend core functionality (connections, lookups, filters).
– **Playbooks**: YAML instructions describing desired state.

**Q: What is idempotence in Ansible?
A: Running the same playbook multiple times yields the same result. Ansible modules are written to check current state before acting, so tasks run only when change is needed.


## 2. Inventory & Variables

**Q: How do you structure a dynamic inventory?
A: Use a Python/Go script or cloud plugin (like `aws_ec2`) returning JSON. In AWS we often use:

plugin: aws_ec2
regions: ["ap-south-1"]
filters: { tag:Role: webserver }


This auto-populates hosts from AWS tags.

**Q: Variable precedence order?
A: From lowest to highest: role defaults → inventory vars → play vars → extra-vars (`-e`) → command-line overrides. `extra-vars` always wins.

**Q: What are facts?
A: Facts are host-level variables collected at runtime by the `setup` module. They’re used to make playbooks OS-aware. Example: `ansible_distribution` to choose package manager.


## 3. Playbooks & Roles

**Q: How do you structure large playbooks?
A: Break into roles with `tasks/`, `handlers/`, `templates/`, `defaults/`, `vars/`, `files/`. Use `roles:` in the playbook to include them. This keeps playbooks DRY and reusable.

**Q: Handlers vs. tasks?
A: Handlers are tasks triggered only when notified (e.g., restart service after config change). Tasks run every time unless conditions prevent them.

**Q: include vs. import?
A: `import_tasks` is static (loaded at parse time); `include_tasks` is dynamic (loaded at runtime, allows loops/conditionals).


## 4. Security

**Q: What is Ansible Vault?
A: It encrypts sensitive data (passwords, API keys) inside YAML files. Use `ansible-vault create|edit|encrypt` to manage. Pass `--ask-vault-pass` or vault IDs in CI/CD to decrypt on the fly.

**Q: How to mask secrets in logs?
A: Use `no_log: true` on sensitive tasks. This hides stdout/stderr from Ansible output.


## 5. Modules & Plugins

**Q: How would you write a custom module?
A: Create a Python script that takes arguments via `AnsibleModule()`. Return JSON with `changed` and `msg`. Place it in `library/` directory so Ansible picks it up automatically.

**Q: Lookup vs. Filter plugins?
A: Lookup plugins fetch data from external sources (files, URLs, cloud). Filters modify data within playbooks (Jinja2 filters like `|default` or custom filters).


## 6. Error Handling & Debugging

**Q: How to handle failed tasks gracefully?
A: Use `ignore_errors: yes` to continue, `failed_when:` to define failure conditions, and `block/rescue/always` for try–catch-like behavior.

**Q: How do you debug a playbook?
A: Run with `ansible-playbook -vvv`. Use `debug:` module to print variables. Temporarily add `gather_facts: yes` to see host info.


## 7. Performance & Scaling

**Q: How to run Ansible faster on thousands of hosts?
A: Increase `forks` in `ansible.cfg` (default 5), use `strategy: free` for parallelism, disable facts if not needed, use asynchronous tasks, and cache facts with Redis.


## 8. Real-World Scenarios

**Q: Describe Ansible + Terraform integration.
A: Terraform provisions infrastructure; once resources are up, it triggers Ansible (via `local-exec` or CI/CD) to configure OS and deploy apps. This gives infra + config management in one pipeline.

**Q: Rolling deployments?
A: Use `serial:` in playbooks. Example: `serial: 2` updates 2 servers at a time. Combine with `delegate_to` or `wait_for` to ensure health checks before moving on.

**Q: Handling multiple OSes?
A: Use facts like `ansible_os_family` in `when:` conditions to pick the right tasks or templates.


## 9. Advanced Features

**Q: ansible-pull use case?
A: Instead of pushing config from control node, nodes pull config from a Git repo. Useful in autoscaling or disconnected environments.

**Q: Check & diff mode?
A: `--check` shows what would change without making changes. `--diff` shows differences in files/templates. Great for audits.

**Q: Delegation?
A: `delegate_to: localhost` runs a task on a different host than the one in inventory. Used for load balancer updates or API calls.


## 🔟 Best Practices

**Q: Repo structure?
A:
ansible/
  inventories/
  roles/
  playbooks/
  group_vars/
  host_vars/
ansible.cfg


Each environment (dev/staging/prod) gets its own inventory & vars.

**Q: Versioning & CI/CD?
A: Store playbooks/roles in Git. Use Molecule + GitHub Actions or Jenkins to test syntax, lint YAML, and run test deployments before merging.


### 📌 Quick Prep Tips

 - Memorize `ansible-playbook` flags (`-i`, `-e`, `--limit`, `--tags`).
 - Practice writing roles & using Ansible Galaxy.
 - Be ready to explain one **end-to-end automation project** you did.


Would you like me to **package these Q\&A into a nicely formatted PDF** (with categories, examples, and tips) so you can study offline?
