-- ==============================================================================
-- Oracle Workflow Standard Package Template
-- Package Spec and Body for Custom Workflow Activity Functions & Event Subscriptions
-- Target: Oracle EBS R12.1 / R12.2 Workflow Engine
-- ==============================================================================

CREATE OR REPLACE PACKAGE XX_CUSTOM_WORKFLOW_PKG AUTHID CURRENT_USER AS
    -- Standard Workflow Procedure Signature
    PROCEDURE process_workflow_step (
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2
    );

    -- Workflow Selector / Callback Procedure
    PROCEDURE selector (
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2
    );

    -- Business Event System (BES) Rule Function
    FUNCTION event_rule_subscription (
        p_subscription_guid IN RAW,
        p_event             IN OUT NOCOPY wf_event_t
    ) RETURN VARCHAR2;

    -- Workflow Starter Utility
    PROCEDURE launch_custom_workflow (
        p_item_type       IN VARCHAR2,
        p_item_key        IN VARCHAR2,
        p_process_name    IN VARCHAR2,
        p_user_id         IN NUMBER,
        p_resp_id         IN NUMBER,
        p_resp_appl_id    IN NUMBER,
        p_custom_param1   IN VARCHAR2,
        p_custom_param2   IN NUMBER
    );
END XX_CUSTOM_WORKFLOW_PKG;
/
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY XX_CUSTOM_WORKFLOW_PKG AS

    PROCEDURE process_workflow_step (
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2
    ) IS
        l_custom_param1 VARCHAR2(240);
        l_custom_param2 NUMBER;
        l_user_id       NUMBER;
    BEGIN
        -- Workflow engine executes function in RUN mode
        IF (funcmode = 'RUN') THEN
            -- Retrieve Item Attributes
            l_custom_param1 := wf_engine.getitemattrtext(itemtype => itemtype, itemkey => itemkey, aname => 'CUSTOM_PARAM1');
            l_custom_param2 := wf_engine.getitemattrnumber(itemtype => itemtype, itemkey => itemkey, aname => 'CUSTOM_PARAM2');
            l_user_id       := wf_engine.getitemattrnumber(itemtype => itemtype, itemkey => itemkey, aname => 'USER_ID');

            -- Implementation Business Logic
            -- (e.g. Validation, DB updates, Routing decisions)
            IF l_custom_param2 > 10000 THEN
                -- Set result to branch in Workflow Diagram
                resultout := 'COMPLETE:APPROVED';
            ELSE
                resultout := 'COMPLETE:AUTO_PROCESSED';
            END IF;

            -- Update custom status attribute
            wf_engine.setitemattrtext(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'STATUS_MESSAGE',
                avalue   => 'Successfully processed step at ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
            );
            RETURN;
        END IF;

        -- Handle Cancel Mode (if workflow is aborted/canceled)
        IF (funcmode = 'CANCEL') THEN
            resultout := 'COMPLETE';
            RETURN;
        END IF;

        -- Handle Timeout Mode
        IF (funcmode = 'TIMEOUT') THEN
            resultout := 'COMPLETE:TIMEOUT';
            RETURN;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            wf_core.context(
                pkg_name  => 'XX_CUSTOM_WORKFLOW_PKG',
                proc_name => 'process_workflow_step',
                arg1      => itemtype,
                arg2      => itemkey,
                arg3      => TO_CHAR(actid),
                arg4      => funcmode
            );
            RAISE;
    END process_workflow_step;

    PROCEDURE selector (
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2
    ) IS
        l_user_id      NUMBER;
        l_resp_id      NUMBER;
        l_resp_appl_id NUMBER;
    BEGIN
        IF (funcmode = 'SET_CTX') THEN
            -- Establish EBS Apps Context
            l_user_id      := wf_engine.getitemattrnumber(itemtype, itemkey, 'USER_ID', TRUE);
            l_resp_id      := wf_engine.getitemattrnumber(itemtype, itemkey, 'RESP_ID', TRUE);
            l_resp_appl_id := wf_engine.getitemattrnumber(itemtype, itemkey, 'RESP_APPL_ID', TRUE);

            IF l_user_id IS NOT NULL AND l_resp_id IS NOT NULL AND l_resp_appl_id IS NOT NULL THEN
                fnd_global.apps_initialize(
                    user_id      => l_user_id,
                    resp_id      => l_resp_id,
                    resp_appl_id => l_resp_appl_id
                );
            END IF;
            resultout := 'COMPLETE';
            RETURN;
        ELSIF (funcmode = 'TEST_CTX') THEN
            -- Validate if current context matches
            resultout := 'COMPLETE';
            RETURN;
        END IF;
    END selector;

    FUNCTION event_rule_subscription (
        p_subscription_guid IN RAW,
        p_event             IN OUT NOCOPY wf_event_t
    ) RETURN VARCHAR2 IS
        l_event_name VARCHAR2(240);
        l_event_key  VARCHAR2(240);
    BEGIN
        l_event_name := p_event.geteventname();
        l_event_key  := p_event.geteventkey();

        -- Custom Event Consumption Logic
        -- e.g. Log event or trigger concurrent request/workflow

        RETURN 'SUCCESS';
    EXCEPTION
        WHEN OTHERS THEN
            wf_core.context('XX_CUSTOM_WORKFLOW_PKG', 'event_rule_subscription', l_event_name, l_event_key);
            wf_event.seterrorinfo(p_event, 'ERROR');
            RETURN 'ERROR';
    END event_rule_subscription;

    PROCEDURE launch_custom_workflow (
        p_item_type       IN VARCHAR2,
        p_item_key        IN VARCHAR2,
        p_process_name    IN VARCHAR2,
        p_user_id         IN NUMBER,
        p_resp_id         IN NUMBER,
        p_resp_appl_id    IN NUMBER,
        p_custom_param1   IN VARCHAR2,
        p_custom_param2   IN NUMBER
    ) IS
    BEGIN
        -- 1. Create Process
        wf_engine.createprocess(
            itemtype => p_item_type,
            itemkey  => p_item_key,
            process  => p_process_name
        );

        -- 2. Set Item Attributes
        wf_engine.setitemattrnumber(p_item_type, p_item_key, 'USER_ID', p_user_id);
        wf_engine.setitemattrnumber(p_item_type, p_item_key, 'RESP_ID', p_resp_id);
        wf_engine.setitemattrnumber(p_item_type, p_item_key, 'RESP_APPL_ID', p_resp_appl_id);
        wf_engine.setitemattrtext(p_item_type, p_item_key, 'CUSTOM_PARAM1', p_custom_param1);
        wf_engine.setitemattrnumber(p_item_type, p_item_key, 'CUSTOM_PARAM2', p_custom_param2);

        -- 3. Set Item User Key and Owner
        wf_engine.setitemuserkey(p_item_type, p_item_key, 'Order_' || p_custom_param1);
        wf_engine.setitemowner(p_item_type, p_item_key, 'SYSADMIN');

        -- 4. Start Process
        wf_engine.startprocess(
            itemtype => p_item_type,
            itemkey  => p_item_key
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END launch_custom_workflow;

END XX_CUSTOM_WORKFLOW_PKG;
/
SHOW ERRORS;
