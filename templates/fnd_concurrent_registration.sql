-- ==============================================================================
-- Oracle EBS Concurrent Program, Executable, Parameters & Request Group Registration API
-- Target: Oracle EBS R12.1 / R12.2
-- Safe, Scripted & Idempotent Implementation
-- ==============================================================================

DECLARE
    -- Definition Variables
    l_application_short_name VARCHAR2(50)  := 'AR';
    l_executable_name        VARCHAR2(50)  := 'XX_AR_INVOICE_REP';
    l_executable_desc        VARCHAR2(240) := 'Custom AR Invoice BI Publisher Extraction Executable';
    l_execution_method       VARCHAR2(50)  := 'PL/SQL Stored Procedure'; -- or 'XDODTEXE' for XML Publisher Data Template
    l_execution_file_name    VARCHAR2(240) := 'XX_AR_REPORT_PKG.run_invoice_extract';
    
    l_program_name           VARCHAR2(50)  := 'XX_AR_INVOICE_REP';
    l_program_user_name      VARCHAR2(240) := 'Custom AR Invoice & Customer Summary Report';
    l_program_desc           VARCHAR2(240) := 'Extracts and formats AR Invoices with BI Publisher layout';
    l_output_type            VARCHAR2(50)  := 'XML'; -- or 'PDF', 'TEXT', 'HTML'

    l_request_group_name     VARCHAR2(240) := 'Receivables All';
    l_request_group_appl     VARCHAR2(50)  := 'AR';
BEGIN
    dbms_output.put_line('------------------------------------------------------------');
    dbms_output.put_line('Starting Concurrent Registration for: ' || l_program_name);
    dbms_output.put_line('------------------------------------------------------------');

    -- 1. Create or Overwrite Executable
    IF fnd_program.executable_exists(l_executable_name, l_application_short_name) THEN
        dbms_output.put_line('Executable exists. Deleting prior instance...');
        fnd_program.delete_executable(l_executable_name, l_application_short_name);
    END IF;

    fnd_program.executable(
        executable          => l_executable_name,
        application         => l_application_short_name,
        short_name          => l_executable_name,
        description         => l_executable_desc,
        execution_method    => l_execution_method,
        execution_file_name => l_execution_file_name
    );
    dbms_output.put_line('1. Executable registered successfully.');

    -- 2. Create Concurrent Program
    IF fnd_program.program_exists(l_program_name, l_application_short_name) THEN
        dbms_output.put_line('Program exists. Deleting prior instance...');
        fnd_program.delete_program(l_program_name, l_application_short_name);
    END IF;

    fnd_program.register(
        program                => l_program_user_name,
        application            => l_application_short_name,
        enabled                => 'Y',
        short_name             => l_program_name,
        description            => l_program_desc,
        executable_short_name  => l_executable_name,
        executable_application => l_application_short_name,
        output_type            => l_output_type,
        use_nl_margins         => 'N',
        save_output            => 'Y',
        print                  => 'N',
        mls_function           => NULL
    );
    dbms_output.put_line('2. Concurrent Program registered successfully.');

    -- 3. Register Program Parameters
    fnd_program.parameter(
        program_short_name => l_program_name,
        application        => l_application_short_name,
        sequence           => 10,
        parameter          => 'P_ORG_ID',
        description        => 'Operating Unit ID',
        value_set          => 'FND_MO_OU_ALL',
        default_type       => 'PROFILE',
        default_value      => 'ORG_ID',
        required           => 'Y',
        enable_security    => 'N',
        display            => 'Y'
    );

    fnd_program.parameter(
        program_short_name => l_program_name,
        application        => l_application_short_name,
        sequence           => 20,
        parameter          => 'P_FROM_DATE',
        description        => 'Invoice Date From',
        value_set          => 'FND_STANDARD_DATE',
        required           => 'N',
        display            => 'Y'
    );

    fnd_program.parameter(
        program_short_name => l_program_name,
        application        => l_application_short_name,
        sequence           => 30,
        parameter          => 'P_TO_DATE',
        description        => 'Invoice Date To',
        value_set          => 'FND_STANDARD_DATE',
        required           => 'N',
        display            => 'Y'
    );

    fnd_program.parameter(
        program_short_name => l_program_name,
        application        => l_application_short_name,
        sequence           => 40,
        parameter          => 'P_STATUS',
        description        => 'Invoice Status',
        value_set          => '240 Characters',
        default_type       => 'CONSTANT',
        default_value      => 'ALL',
        required           => 'N',
        display            => 'Y'
    );
    dbms_output.put_line('3. Parameters registered successfully.');

    -- 4. Assign to Request Group
    BEGIN
        fnd_program.add_to_group(
            program_short_name  => l_program_name,
            program_application => l_application_short_name,
            request_group       => l_request_group_name,
            group_application   => l_request_group_appl
        );
        dbms_output.put_line('4. Assigned to Request Group: ' || l_request_group_name);
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Warning: Request group assignment skipped: ' || SQLERRM);
    END;

    COMMIT;
    dbms_output.put_line('------------------------------------------------------------');
    dbms_output.put_line('Registration Complete and Committed.');
    dbms_output.put_line('------------------------------------------------------------');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('ERROR during concurrent registration: ' || SQLERRM);
        RAISE;
END;
/
SHOW ERRORS;
