package policy

# Define the expected predicateSlugs
expected_predicate_slugs := {"approval"}

# Collect all predicateSlugs found in the input JSON
found_predicate_slugs := {slug |
    some i, j
    slug := input.data.releaseBundleVersion.getVersion.artifactsConnection.edges[i].node.evidenceConnection.edges[j].node.predicateSlug
} | {slug |
    some k, l
    slug := input.data.releaseBundleVersion.getVersion.fromBuilds[k].evidenceConnection.edges[l].node.predicateSlug
} | {slug |
    some m
    slug := input.data.releaseBundleVersion.getVersion.evidenceConnection.edges[m].node.predicateSlug
}

found := [slug | slug := found_predicate_slugs[_]]

not_found := [slug | slug := expected_predicate_slugs[_]; not found_predicate_slugs[slug]]

approver := {slug |
    some m
    slug := input.data.releaseBundleVersion.getVersion.evidenceConnection.edges[m].node.predicate.actor
}

# Check if "approval" evidence exists and was created by tpaz1
approved if {
    "approval" in found_predicate_slugs
    approver == {"tpaz1"}
}

output := {
    "found": found,
    "not_found": not_found,
    "approved": approved,
    "approver": approver
}

default approved = false
default output = {"found": [], "approved": false}
