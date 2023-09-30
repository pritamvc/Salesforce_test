<aura:application extends="force:slds">

    <aura:attribute name="selectedRecord" type="object" access="private" />

    <lightning:card title="Narrow Card Header">

        <p class="slds-p-around_large">

           <c:lookupDemo uniqueName="MyUser" 
                               objectAPIName="User"

                               labelHidden="true"
                               where="isActive = true"
                               selectedRecord="{!v.selectedRecord}"
                               oncustomLookupUpdateEvent="{!c.handleSelection}"/>
        </p>

    </lightning:card>

    {!v.selectedRecord}

</aura:application>