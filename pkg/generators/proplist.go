package generators

import (
	"time"

	argoprojiov1alpha1 "github.com/argoproj-labs/applicationset/api/v1alpha1"
)

var _ Generator = (*PropListGenerator)(nil)

type PropListGenerator struct {
}

func NewPropListGenerator() Generator {
	g := &PropListGenerator{}
	return g
}

func (g *PropListGenerator) GetRequeueAfter(appSetGenerator *argoprojiov1alpha1.ApplicationSetGenerator) time.Duration {
	return NoRequeueAfter
}

func (g *PropListGenerator) GenerateParams(appSetGenerator *argoprojiov1alpha1.ApplicationSetGenerator) ([]map[string]string, error) {
	if appSetGenerator == nil {
		return nil, EmptyAppSetGeneratorError
	}

	if appSetGenerator.PropList == nil {
		return nil, nil
	}

	res := make([]map[string]string, 1)

	params := make(map[string]string, len(appSetGenerator.PropList.Elements))
	for _, tmpItem := range appSetGenerator.PropList.Elements {
		params[tmpItem.Name] = tmpItem.Value
	}
	res[0] = params

	return res, nil
}
