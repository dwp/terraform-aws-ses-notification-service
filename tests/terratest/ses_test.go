package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"path/filepath"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// Terratest functions for testing the ses notifcation module
func TestSES(t *testing.T) {
	t.Parallel()

	// AWS Region set as eu-west-1 as standard.
	awsRegion := "eu-west-1"

	// set up variables for other module variables so assertions may be made on them later

	// Terraform plan.out File Path
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "example/")
	planFilePath := filepath.Join(exampleFolder, "plan.out")


	terraformOptionsSES := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../example",
		Upgrade:      true,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{

		},

		//Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},

		// Configure a plan file path so we can introspect the plan and make assertions about it.
		PlanFilePath: planFilePath,
	})

	// website::tag::2::Run `terraform init`, `terraform plan`, and `terraform show` and fail the test if there are any errors
	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptionsSES)


	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptionsSES)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptionsSES)

	// website::tag::3::Use the go struct to introspect the plan values.
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.ses_notification_service.aws_iam_role.lambda_sns_to_ses_mailer")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.ses_notification_service.aws_ses_domain_identity.domain_identity")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.ses_notification_service.aws_s3_bucket.ses_mailer_bucket")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.ses_notification_service.aws_lambda_function.sns_to_ses_mailer")


	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptionsSES, "bucket_id")
	lambdaArn := terraform.Output(t, terraformOptionsSES, "lambda_arn")


	// Verify that our Bucket has been created
	assert.Equal(t, bucketID, "dwx-test-ses-bucket", "Bucket ID must match")

	// Checks Lambda arn exists
	lengthOflambdaArn := len(lambdaArn)
	assert.NotEqual(t, lengthOflambdaArn, 0, "ARN Output MUST be populated")
}
