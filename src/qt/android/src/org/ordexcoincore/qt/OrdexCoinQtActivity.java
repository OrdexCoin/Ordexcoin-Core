package org.ordexcoincore.qt;

import android.os.Bundle;
import android.system.ErrnoException;
import android.system.Os;

import org.qtproject.qt5.android.bindings.QtActivity;

import java.io.File;

public class OrdexCoinQtActivity extends QtActivity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        final File ordexcoinDir = new File(getFilesDir().getAbsolutePath() + "/.ordexcoin");
        if (!ordexcoinDir.exists()) {
            ordexcoinDir.mkdir();
        }

        super.onCreate(savedInstanceState);
    }
}
