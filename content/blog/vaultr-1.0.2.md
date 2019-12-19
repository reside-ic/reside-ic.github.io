---
author: "Rich FitzJohn"
date: 2019-05-16
title: vaultr 1.0.2
best: false
tags:
 - R
 - security
---

We are pleased to announce the first public release of `vaultr`, our R client for [HashiCorp's "vault"](https://vaultproject.io), a system for storing secrets and sensitive data and enabling these secrets to be used in applications.

Vault (the server) is a little like a password manager (e.g., [LastPass](https://www.lastpass.com/business-password-manager) or [Bitwarden](https://bitwarden.com/)) but designed for use within applications, rather than for storing personal passwords.  With vault, you can have a central source of secrets and sensitive data (ssh keys, database passwords, ssl certificates) that can be used when deploying or using applications.  This makes it much easier to avoid writing these secrets to disk in plain text while still allowing automated use of secrets.

We have been using vault internally for 2 years, often through the command line interface or through the [python package](https://python-hvac.org/), but also through our R package [`vaultr`](https://vimc.github.io/vaultr/).

With `vaultr`, logging-in, writing and reading a secret from a central store can be done with very little code:
```
vault <- vaultr::vault_client(login = TRUE)
vault$write("/secret/database/users/readonly", list(password = "s3cret!"))
vault$read("/secret/database/users/readonly")
#> $password
#> [1] "s3cret!"
```

This package allows access to a large fraction of vault's api, including:

* Authentication via [username/password](https://www.vaultproject.io/docs/auth/userpass.html), via [GitHub](https://www.vaultproject.io/docs/auth/github.html), as well as an ["AppRole" method](https://www.vaultproject.io/docs/auth/approle.html) (designed for machine-based authentication)
* Secrets stored in two key-value stores (one [simple and unversioned](https://www.vaultproject.io/docs/secrets/kv/kv-v1.html), the other [allowing versioning and metadata](https://www.vaultproject.io/docs/secrets/kv/kv-v2.html)), the [cubbyhole](https://www.vaultproject.io/docs/secrets/cubbyhole/index.html) storage system for token-scoped secrets, and vault's [transit engine](https://www.vaultproject.io/docs/secrets/transit/index.html) for "encryption-as-a-service".

In order to develop R packages that use vault, we have added support for starting and controlling vault servers in ["Dev" server mode](https://www.vaultproject.io/docs/concepts/dev-server.html).

`vaultr` is now available from CRAN and can be installed with

```
install.packages("vaultr")
```

To get started see [the package vignette](https://vimc.github.io/vaultr/articles/vaultr.html).
