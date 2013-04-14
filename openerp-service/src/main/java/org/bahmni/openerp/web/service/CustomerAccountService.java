package org.bahmni.openerp.web.service;

import org.apache.log4j.Logger;
import org.bahmni.openerp.web.client.OpenERPClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Vector;

@Service
public class CustomerAccountService {
    OpenERPClient openERPClient;
    private static Logger logger = Logger.getLogger(CustomerAccountService.class);

    @Autowired
    public CustomerAccountService(OpenERPClient client){
        this.openERPClient = client;
    }

    public void updateCustomerReceivables(String patientId,double amount) {
        Object args1[]={"partner_id",patientId};
        Object args2[]={"amount",amount};
        Vector params = new Vector();
        params.addElement(args1);
        params.addElement(args2);

        try{
            openERPClient.updateCustomerReceivables("account.invoice",params);
        }catch(Exception e){
            String message = "Account Receivable update failed for "+ patientId +": amount "+amount;
            logger.error(message+ " /n"+ e.getMessage() + "/n" + e.getStackTrace());
            throw new RuntimeException(message,e);
        }
    }
}
