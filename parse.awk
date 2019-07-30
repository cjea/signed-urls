# parse.awk
# parse a configuration into a signed url for gcs bucket
# Example config:
#
#   put request
#   gs://foo bucket
#   private key is /keypath
#   lasts for 5m
#   plain/text content type
#
# outputs the string:
#
# gsutil signurl -d 5m -m PUT -r us-central1 -c plain/text /keypath gs://foo

BEGIN {
  methods = "/GET|PUT|POST|DELETE/"
  cfg["r"] = "us-central1"
  cfg["m"] = "GET"
  keypath="/keybase/team/lrnexus/signed-url-svc-user-private-key.pem"
}

toupper($0) ~ methods {
  for (i = 1; i <= NF; i++) {
    m = toupper($i)
    if (m ~ methods) {
      cfg["m"] = m
      next;
    }
  }
  check(cfg["m"])
}

/private/ || /key/ { keypath = $NF; next; }

/gs:\/\// {
  for (i = 1; i <= NF; i++) {
    if ($i ~ /gs:\/\//) {
      bucket = $i;
      next;
    }
  }
  check(bucket)
}

/region/ { cfg["r"] = $NF; next; }

/dur/ || /expir/ || /last/ {
  for (i = 1; i <= NF; i++) {
    if ($i ~ /[0-9]+/) {
      cfg["d"] = $i
      next;
    }
  }
  check(cfg["d"])
}

/content/ {
  for (i = 1; i <= NF; i++) {
    if ($i !~ /content|type|is|of/) {
      cfg["c"] = $i
      next;
    }
  }
  check(cfg["c"])
}

{ print "didn't understand: " $0 }

END {
  if (keypath == "" || bucket == ""){
    print "must set both private key and bucket";
    exit;
  }
  print "gsutil signurl" flagstr() " " keypath " " bucket

}

function check(val) {
  if (val == "")
    print "didn't understand: " $0
}

function flagstr() {
  for (k in cfg) {
    flags = flags " -" k " " cfg[k]
  }
  return flags
}
