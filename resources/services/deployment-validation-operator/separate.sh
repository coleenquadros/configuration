grep '# deployment_validation_operator_' /var/tmp/prometheusrules.yaml.j2 | sed 's/.*deployment_validation_operator_//' | while read i
do
    new_rules_file=prometheusrules-$i.yaml.j2
    #sed "s/deployment-validation-operator.rules/deployment-validation-operator-$i.rules/" prometheusrules.yaml.j2 > "$new_rules_file"

    new_prometheus_tests_file=prometheusrulestests-$i.yaml
    #sed "s/prometheusrules.yaml.j2/$new_rules_file/" prometheusrulestests.yaml > "$new_prometheus_tests_file"

    new_tests_file="test/expected_result-$i.yml"
    #sed "s/deployment-validation-operator.rules/deployment-validation-operator-$i.rules/" test/expected_result.yml > "$new_tests_file"
    sed -i"" -e "s/prometheusrules.yaml.j2/$new_rules_file/" "$new_tests_file"
done
