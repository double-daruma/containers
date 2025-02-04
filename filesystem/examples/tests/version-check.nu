#!/usr/bin/env nu




def github_version (proj: string) : any -> string {
    print $"Fetching latest version from github for ($proj)"
    sleep 5sec
    http get $"https://api.github.com/repos/($proj)/releases/latest" | get tag_name | str trim --left --char=v
}


def filter_version () : string -> string {
  parse --regex '(?<version>([0-9]+)\.([0-9]+)(.[0-9]+)?)' | get version | first
}

def get_local_version (cmd: string) : any -> string {
    try {
        let output = run-external $cmd '--version' | lines
        print $"Getting the version for ($cmd) is ($output)"
        let parsed_version = $output | first | filter_version 
        print $"Parsed the version for ($cmd) as ($parsed_version)"
        $parsed_version
    } catch { |err|
        print $"Running ($cmd) failed: ($err.msg)"
        "error"
    }
}


def get_versions (user: string, repo: string, local: string) : any -> record {
    {program: $repo, local: (get_local_version $local), latest: (github_version $"($user)/($repo)") }
}

def x (user: string, repo: string) : any -> record {
    get_versions $user $repo $repo
}

let versions1 = [
    [ program     local                         latest]; 
    [ cue     (cue version | lines | first | filter_version)      (github_version 'cue-lang/cue')]
]

let versions2 = [
    (get_versions nushell nushell nu)
    (x gleam-lang gleam)
    (x casey just)
    (x typst typst)
    (x zellij-org zellij)
    (x starship starship)
    (x denoland deno)
    (x getzola zola)
    (x jj-vcs jj)
    (x erlang rebar3)
]


# todo rg fd bat

let versions = $versions1 | append $versions2



print ($versions | insert is_up_to_date { |row| $row.local == $row.latest })